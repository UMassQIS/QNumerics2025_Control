import Pkg; Pkg.activate(@__DIR__); Pkg.instantiate()

using Piccolo
using Piccolissimo
using LinearAlgebra
using QuantumToolbox
using CairoMakie

# ── System ────────────────────────────────────────────────────────────────────

n_levels = 35

a  = annihilate(n_levels)
X  = a + a'
Y  = -im * (a - a')
X2 = a^2 + (a')^2
Y2 = -im * (a^2 - (a')^2)

# Linear (displacement) and quadratic (squeezing) drives on a single oscillator
sys = QuantumSystem([X, Y, X2, Y2], [1.0, 1.0, 0.5, 0.5])

# ── Target state ──────────────────────────────────────────────────────────────

# Square GKP |0_L⟩ state: superposition of coherent states on a q-quadrature grid
#   q-peaks at q = 2n√π  →  coherent amplitudes α_n = n√(2π)
# Gaussian envelope exp(-Δ²π n²), Δ ≈ 0.3 corresponds to ~10 dB squeezing
Δ_gkp = 0.3
S_gkp = 2   # truncate sum to n ∈ {-S, …, S}  (5 peaks)

ψ0 = I(n_levels)[:, 1] .+ 0.0im   # Fock vacuum

function displacement_op(α)
    return exp(α * a' - conj(α) * a)
end

ψ_gkp = normalize(
    sum(exp(-Δ_gkp^2 * π * n^2) * displacement_op(n * √(2π)) * ψ0 for n in -S_gkp:S_gkp)
)

# Ground truth in a larger Hilbert space for fidelity validation
N_qt = 100
ψ_gkp_qt = normalize(
    sum(exp(-Δ_gkp^2 * π * n^2) * coherent(N_qt, n * √(2π)) for n in -S_gkp:S_gkp)
)

qt_trunc = normalize(ψ_gkp_qt.data[1:n_levels])
@show abs2(dot(ψ_gkp, qt_trunc))   # truncation fidelity check

# ── Optimization ──────────────────────────────────────────────────────────────

N  = 100
Δt = 0.5
T  = Δt * (N - 1)

pulse = CubicSplinePulse(0.1 * randn(4, N), zeros(4, N), collect(range(0, T, length=N)))

qtraj = KetTrajectory(sys, pulse, ψ0, ψ_gkp)
integrator = SplineIntegrator(qtraj, N)

ucp = SplinePulseProblem(qtraj, N; integrator=integrator)

solve!(ucp, max_iter=500, options=IpoptOptions(eval_hessian=true))

# ── Visualization ─────────────────────────────────────────────────────────────

traj = get_trajectory(ucp)

Piccolo.Rollouts.fidelity(ucp)

# GKP peaks at q = 2n√π ≈ ±7.1 for n = ±2; extend axes to capture the full grid
wigner_kw = (xvec = -8:0.1:8, yvec = -8:0.1:8)

# Target state Wigner function (ground truth)
fig_qt = plot_wigner(ψ_gkp_qt; wigner_kw...)
display(fig_qt[1])

# Optimized final state Wigner function
fig_opt = plot_wigner(traj, N; wigner_kw...)

animate_wigner(traj, mode=:record, filename="gkp_state_prep_wigner.gif", fps=10; wigner_kw...)
