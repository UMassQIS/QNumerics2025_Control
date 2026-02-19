import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

using Piccolo
using Piccolissimo
using LinearAlgebra
using CairoMakie

# ── System ────────────────────────────────────────────────────────────────────

n_qubits = 2

X1 = lift_operator(PAULIS.X, 1, n_qubits)
Y1 = lift_operator(PAULIS.Y, 1, n_qubits)
X2 = lift_operator(PAULIS.X, 2, n_qubits)
Y2 = lift_operator(PAULIS.Y, 2, n_qubits)

J = 0.5
Z1 = lift_operator(PAULIS.Z, 1, n_qubits)
Z2 = lift_operator(PAULIS.Z, 2, n_qubits)
H_drift = J * Z1 * Z2

sys = QuantumSystem(H_drift, [X1, Y1, X2, Y2], fill(1.0, 4))

# ── Target gate ───────────────────────────────────────────────────────────────

U_goal = GATES.CZ

# ── Optimization ──────────────────────────────────────────────────────────────

N = 21          # fewer knot points — cubic spline interpolates between them
T = 10.0

pulse = CubicSplinePulse(0.1 * randn(4, N), zeros(4, N), collect(range(0, T, length=N)))
utraj = UnitaryTrajectory(sys, pulse, U_goal)

integrator = SplineIntegrator(utraj, N)

ucp = SplinePulseProblem(utraj, N; integrator=integrator)

solve!(ucp, max_iter=100, options=IpoptOptions(eval_hessian=true))

# ── Check results ─────────────────────────────────────────────────────────────

fidelity = Piccolo.Quantum.Rollouts.fidelity(ucp)
traj = get_trajectory(ucp)

qcp_min = MinimumTimeProblem(ucp, final_fidelity=0.99)
solve!(qcp_min, max_iter=100, options=IpoptOptions(eval_hessian=true))
fidelity = Piccolo.Quantum.Rollouts.fidelity(qcp_min)

T_before = sum(get_timesteps(get_trajectory(ucp)))
T_min = sum(get_timesteps(get_trajectory(qcp_min)))