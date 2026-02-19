import Pkg;
Pkg.activate(joinpath(@__DIR__, ".."));
Pkg.instantiate();

using Piccolo
using Piccolissimo
using LinearAlgebra
using CairoMakie
using QuantumToolbox

# ── System ────────────────────────────────────────────────────────────────────

n_levels = 10

a = annihilate(n_levels)
X = a + a'
Y = -im * (a - a')
X2 = a^2 + (a')^2
Y2 = -im * (a^2 - (a')^2)

sys = QuantumSystem([X, Y, X2, Y2], [1.0, 1.0, 0.5, 0.5])

ψ0 = I(n_levels)[:, 1] .+ 0.0im

# ── Target state ──────────────────────────────────────────────────────────────

# Three-legged cat state: superposition of 3 coherent states at 120° apart
# ρ_cat = 2.5: |α|² ≈ 6.25, ~99% captured in 10 Fock levels
ρ_cat = 2.5
α1 = ρ_cat * exp(im * π / 2)
α2 = ρ_cat * exp(im * (π / 2 + 2π / 3))
α3 = ρ_cat * exp(im * (π / 2 + 4π / 3))

# coherent_ket from Piccolissimo: direct Fock-space expansion of |α⟩
ψ_cat3 = normalize(
    coherent_ket(α1, n_levels) +
    coherent_ket(α2, n_levels) +
    coherent_ket(α3, n_levels)
)

# Ground truth via QuantumToolbox (N=30, independent of n_levels)
N_qt = 30
ψ_cat3_qt = normalize(coherent(N_qt, α1) + coherent(N_qt, α2) + coherent(N_qt, α3))

# Fidelity check: how well does the truncated target match ground truth
qt_trunc = normalize(ψ_cat3_qt.data[1:n_levels])
@show abs2(dot(ψ_cat3, qt_trunc))

# ── Optimization ──────────────────────────────────────────────────────────────

N_cat = 101
Δt_cat = 0.4
T_cat = Δt_cat * (N_cat - 1)

pulse_cat = ZeroOrderPulse(0.1 * randn(4, N_cat), collect(range(0, T_cat, length=N_cat)))
qtraj_cat = KetTrajectory(sys, pulse_cat, ψ0, ψ_cat3)

# HermitianExponentialIntegrator: exact matrix exponential for piecewise-constant controls
integrator = HermitianExponentialIntegrator(qtraj_cat, N_cat)

qcp_cat = SmoothPulseProblem(qtraj_cat, N_cat; integrator=integrator)

solve!(qcp_cat, max_iter=200, options=IpoptOptions(eval_hessian=true))

# ── Visualization ─────────────────────────────────────────────────────────────

# Ground truth Wigner
fig_qt = plot_wigner(ψ_cat3_qt)
display(fig_qt[1])

# Optimized final state Wigner
traj_cat = get_trajectory(qcp_cat)
fig_opt = plot_wigner(traj_cat, N_cat)
plot_state_populations(traj_cat, N_cat)
animate_wigner(traj_cat)
