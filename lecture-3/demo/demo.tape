# ── VHS Demo Tape ─────────────────────────────────────────────────────────────
Output demo.mp4

Set FontSize 36
Set Width 1700
Set Height 2200
Set Theme "Pro"
Set TypingSpeed 80ms

Sleep 3s

# ── Start Julia ───────────────────────────────────────────────────────────────
Type "julia --project"
Enter
Sleep 8s

# ══════════════════════════════════════════════════════════════════════════════
# FIRST RUN — JIT warmup
# ══════════════════════════════════════════════════════════════════════════════

Type "import Pkg;"
Enter
Sleep 500ms
Type "Pkg.activate(@__DIR__);"
Enter
Sleep 1s
Type "Pkg.instantiate();"
Enter
Sleep 10s

Type "using Piccolo"
Enter
Sleep 30s
Type "using Piccolissimo"
Enter
Sleep 10s
Type "using LinearAlgebra"
Enter
Sleep 2s
Type "using CairoMakie"
Enter
Sleep 15s

Type "# ── System ────────────────────────────────────────────────────────────────────"
Enter

Type "n_qubits = 2"
Enter

Type "X1 = lift_operator(PAULIS.X, 1, n_qubits)"
Enter
Type "Y1 = lift_operator(PAULIS.Y, 1, n_qubits)"
Enter
Type "X2 = lift_operator(PAULIS.X, 2, n_qubits)"
Enter
Type "Y2 = lift_operator(PAULIS.Y, 2, n_qubits)"
Enter

Type "J = 0.5"
Enter
Type "Z1 = lift_operator(PAULIS.Z, 1, n_qubits)"
Enter
Type "Z2 = lift_operator(PAULIS.Z, 2, n_qubits)"
Enter
Type "H_drift = J * Z1 * Z2"
Enter

Type "# ── Target gate ───────────────────────────────────────────────────────────────"
Enter
Type "U_goal = GATES.CZ"
Enter

Type "sys = QuantumSystem(H_drift, [X1, Y1, X2, Y2], fill(1.0, 4))"
Enter

Type "N = 21          # fewer knot points — cubic spline interpolates between them"
Enter
Type "T = 10.0"
Enter

Type "pulse = CubicSplinePulse(0.1 * randn(4, N), zeros(4, N), collect(range(0, T, length=N)))"
Enter
Type "utraj = UnitaryTrajectory(sys, pulse, U_goal)"
Enter

Type "integrator = SplineIntegrator(utraj, N)"
Enter

Type "ucp = SplinePulseProblem(utraj, N; integrator=integrator)"
Enter
Sleep 20s

Type "solve!(ucp, max_iter=100, options=IpoptOptions(eval_hessian=true))"
Enter
Sleep 8s

Type "# ── Check results ─────────────────────────────────────────────────────────────"
Enter
Type "fidelity = Piccolo.Quantum.Rollouts.fidelity(ucp)"
Enter
Type "traj = get_trajectory(ucp)"
Enter

Type "qcp_min = MinimumTimeProblem(ucp, final_fidelity=0.99)"
Enter
Type "solve!(qcp_min, max_iter=100, options=IpoptOptions(eval_hessian=true))"
Enter
Sleep 8s

Type "fidelity = Piccolo.Quantum.Rollouts.fidelity(qcp_min)"
Enter
Type "T_before = sum(get_timesteps(get_trajectory(ucp)))"
Enter
Type "T_min = sum(get_timesteps(get_trajectory(qcp_min)))"
Enter
Sleep 2s

# ── Clear and run the real demo ───────────────────────────────────────────────
Ctrl+L
Sleep 1s

# ══════════════════════════════════════════════════════════════════════════════
# SECOND RUN — JIT-warmed demo
# ══════════════════════════════════════════════════════════════════════════════

Type "using Piccolo"
Enter
Sleep 1s
Type "using Piccolissimo"
Enter
Sleep 1s
Type "using LinearAlgebra"
Enter
Sleep 1s
Type "using CairoMakie"
Enter
Sleep 1s

Type "# ── System ──"
Enter

Type "n_qubits = 2"
Enter

Type "X1 = lift_operator(PAULIS.X, 1, n_qubits)"
Enter
Type "Y1 = lift_operator(PAULIS.Y, 1, n_qubits)"
Enter
Type "X2 = lift_operator(PAULIS.X, 2, n_qubits)"
Enter
Type "Y2 = lift_operator(PAULIS.Y, 2, n_qubits)"
Enter

Type "J = 0.5"
Enter
Type "Z1 = lift_operator(PAULIS.Z, 1, n_qubits)"
Enter
Type "Z2 = lift_operator(PAULIS.Z, 2, n_qubits)"
Enter
Type "H_drift = J * Z1 * Z2"
Enter

Type "# ── Target gate ──"
Enter
Type "U_goal = GATES.CZ"
Enter

Type "sys = QuantumSystem(H_drift, [X1, Y1, X2, Y2], fill(1.0, 4))"
Enter

Type "N = 21          # fewer knot points — cubic spline interpolates between them"
Enter
Type "T = 10.0"
Enter

Type "pulse = CubicSplinePulse(0.1 * randn(4, N), zeros(4, N), collect(range(0, T, length=N)))"
Enter
Sleep 1s
Type "utraj = UnitaryTrajectory(sys, pulse, U_goal)"
Enter
Sleep 1s

Type "integrator = SplineIntegrator(utraj, N)"
Enter
Sleep 1s

Type "ucp = SplinePulseProblem(utraj, N; integrator=integrator)"
Enter
Sleep 1s

Type "solve!(ucp, max_iter=100, options=IpoptOptions(eval_hessian=true))"
Enter
Sleep 5s

Type "# ── Check results ─────────────────────────────────────────────────────────────"
Enter
Type "fidelity = Piccolo.Quantum.Rollouts.fidelity(ucp)"
Enter
Type "traj = get_trajectory(ucp)"
Enter

Type "qcp_min = MinimumTimeProblem(ucp, final_fidelity=0.99)"
Enter
Type "solve!(qcp_min, max_iter=100, options=IpoptOptions(eval_hessian=true))"
Enter
Sleep 5s

Type "fidelity = Piccolo.Quantum.Rollouts.fidelity(qcp_min)"
Enter
Type "T_before = sum(get_timesteps(get_trajectory(ucp)))"
Enter
Type "T_min = sum(get_timesteps(get_trajectory(qcp_min)))"
Enter
Sleep 3s
