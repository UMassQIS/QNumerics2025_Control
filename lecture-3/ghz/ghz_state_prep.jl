import Pkg;
Pkg.activate(joinpath(@__DIR__, ".."));
Pkg.instantiate()

using Piccolo
using Piccolissimo
using LinearAlgebra
using QuantumToolbox
using CairoMakie

# ── System ────────────────────────────────────────────────────────────────────

n_qubits = 3

# Single-qubit drives lifted to 3-qubit Hilbert space
X1 = lift_operator(PAULIS.X, 1, n_qubits)
Y1 = lift_operator(PAULIS.Y, 1, n_qubits)
X2 = lift_operator(PAULIS.X, 2, n_qubits)
Y2 = lift_operator(PAULIS.Y, 2, n_qubits)
X3 = lift_operator(PAULIS.X, 3, n_qubits)
Y3 = lift_operator(PAULIS.Y, 3, n_qubits)

# ZZ coupling drift for entanglement generation
J = 0.1
Z1 = lift_operator(PAULIS.Z, 1, n_qubits)
Z2 = lift_operator(PAULIS.Z, 2, n_qubits)
Z3 = lift_operator(PAULIS.Z, 3, n_qubits)
H_drift = J * (Z1 * Z2 + Z2 * Z3)

sys = QuantumSystem(H_drift, [X1, Y1, X2, Y2, X3, Y3], fill(1.0, 6))

# ── Target state ──────────────────────────────────────────────────────────────

ψ0   = ket_from_bitstring("000")
ψ111 = ket_from_bitstring("111")

ψ_ghz = normalize(ψ0 + ψ111)

# ── Optimization ──────────────────────────────────────────────────────────────

N  = 50
Δt = 0.2
T  = Δt * (N - 1)

pulse = CubicSplinePulse(0.1 * randn(6, N), zeros(6, N), collect(range(0, T, length=N)))

qtraj = KetTrajectory(sys, pulse, ψ0, ψ_ghz)
integrator = SplineIntegrator(qtraj, N)

ucp = SplinePulseProblem(qtraj, N; integrator=integrator)

solve!(ucp, max_iter=500, options=IpoptOptions(eval_hessian=true))

# ── Visualization ─────────────────────────────────────────────────────────────

traj = get_trajectory(ucp)

Piccolo.Rollouts.fidelity(ucp)

# Population of each computational basis state over the trajectory
fig = plot(
    traj, [:u],
    transformations = [:ψ̃ => ψ̃ -> abs2.(iso_to_ket(ψ̃))],
    transformation_titles = ["Population"],
    use_autolimits = true,
)
display(fig)
animate_wigner(traj, mode=:record, filename="ghz_state_prep_wigner.gif", fps=10)
