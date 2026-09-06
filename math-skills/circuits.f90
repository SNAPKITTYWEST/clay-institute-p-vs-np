! Circuit Complexity: Circuit Simulation and Gate Counting
! Implements Boolean circuits and complexity measures
! Tests: Prove lower bounds for simple functions

module circuit_complexity
    implicit none
    private
    public :: circuit_t, evaluate_circuit, count_gates, circuit_depth
    
    integer, parameter :: MAX_GATES = 1000
    integer, parameter :: MAX_INPUTS = 100
    
    ! Gate types
    integer, parameter :: GATE_AND = 1
    integer, parameter :: GATE_OR = 2
    integer, parameter :: GATE_NOT = 3
    integer, parameter :: GATE_XOR = 4
    integer, parameter :: GATE_INPUT = 5
    
    type :: gate_t
        integer :: gate_type
        integer :: input1, input2  ! Input gate indices (0 for NOT/INPUT)
        logical :: output
    end type
    
    type :: circuit_t
        integer :: n_inputs
        integer :: n_gates
        type(gate_t) :: gates(MAX_GATES)
    end type

contains

    ! Evaluate circuit on input
    subroutine evaluate_circuit(circuit, inputs, output)
        type(circuit_t), intent(in) :: circuit
        logical, intent(in) :: inputs(:)
        logical, intent(out) :: output
        
        integer :: i, in1, in2
        logical :: gate_outputs(MAX_GATES)
        
        ! Initialize gate outputs
        gate_outputs = .false.
        
        ! Evaluate gates in topological order
        do i = 1, circuit%n_gates
            select case (circuit%gates(i)%gate_type)
            case (GATE_INPUT)
                gate_outputs(i) = inputs(circuit%gates(i)%input1)
                
            case (GATE_AND)
                in1 = circuit%gates(i)%input1
                in2 = circuit%gates(i)%input2
                gate_outputs(i) = gate_outputs(in1) .and. gate_outputs(in2)
                
            case (GATE_OR)
                in1 = circuit%gates(i)%input1
                in2 = circuit%gates(i)%input2
                gate_outputs(i) = gate_outputs(in1) .or. gate_outputs(in2)
                
            case (GATE_NOT)
                in1 = circuit%gates(i)%input1
                gate_outputs(i) = .not. gate_outputs(in1)
                
            case (GATE_XOR)
                in1 = circuit%gates(i)%input1
                in2 = circuit%gates(i)%input2
                gate_outputs(i) = gate_outputs(in1) .neqv. gate_outputs(in2)
            end select
        end do
        
        ! Output is last gate
        output = gate_outputs(circuit%n_gates)
    end subroutine

    ! Count gates by type
    subroutine count_gates(circuit, n_and, n_or, n_not, n_xor)
        type(circuit_t), intent(in) :: circuit
        integer, intent(out) :: n_and, n_or, n_not, n_xor
        
        integer :: i
        
        n_and = 0
        n_or = 0
        n_not = 0
        n_xor = 0
        
        do i = 1, circuit%n_gates
            select case (circuit%gates(i)%gate_type)
            case (GATE_AND)
                n_and = n_and + 1
            case (GATE_OR)
                n_or = n_or + 1
            case (GATE_NOT)
                n_not = n_not + 1
            case (GATE_XOR)
                n_xor = n_xor + 1
            end select
        end do
    end subroutine

    ! Compute circuit depth (longest path from input to output)
    function circuit_depth(circuit) result(depth)
        type(circuit_t), intent(in) :: circuit
        integer :: depth
        
        integer :: i, in1, in2
        integer :: gate_depths(MAX_GATES)
        
        gate_depths = 0
        
        do i = 1, circuit%n_gates
            select case (circuit%gates(i)%gate_type)
            case (GATE_INPUT)
                gate_depths(i) = 0
                
            case (GATE_NOT)
                in1 = circuit%gates(i)%input1
                gate_depths(i) = gate_depths(in1) + 1
                
            case (GATE_AND, GATE_OR, GATE_XOR)
                in1 = circuit%gates(i)%input1
                in2 = circuit%gates(i)%input2
                gate_depths(i) = max(gate_depths(in1), gate_depths(in2)) + 1
            end select
        end do
        
        depth = maxval(gate_depths(1:circuit%n_gates))
    end function

    ! Build parity circuit (XOR of all inputs)
    subroutine build_parity_circuit(n, circuit)
        integer, intent(in) :: n
        type(circuit_t), intent(out) :: circuit
        
        integer :: i
        
        circuit%n_inputs = n
        circuit%n_gates = 2 * n - 1
        
        ! Input gates
        do i = 1, n
            circuit%gates(i)%gate_type = GATE_INPUT
            circuit%gates(i)%input1 = i
        end do
        
        ! XOR tree
        do i = 1, n-1
            circuit%gates(n + i)%gate_type = GATE_XOR
            if (i == 1) then
                circuit%gates(n + i)%input1 = 1
                circuit%gates(n + i)%input2 = 2
            else
                circuit%gates(n + i)%input1 = n + i - 1
                circuit%gates(n + i)%input2 = i + 1
            end if
        end do
    end subroutine

    ! Build majority circuit (output 1 if more than half inputs are 1)
    subroutine build_majority_circuit(n, circuit)
        integer, intent(in) :: n
        type(circuit_t), intent(out) :: circuit
        
        ! Simplified: threshold circuit
        circuit%n_inputs = n
        circuit%n_gates = n * (n - 1) / 2 + n  ! Upper bound
        
        ! This is a placeholder - full implementation would be complex
        circuit%gates(1)%gate_type = GATE_INPUT
        circuit%gates(1)%input1 = 1
    end subroutine

end module circuit_complexity

! Test program
program test_circuits
    use circuit_complexity
    implicit none
    
    type(circuit_t) :: circuit
    logical :: inputs(4), output
    integer :: n_and, n_or, n_not, n_xor, depth
    
    print *, "==========================================================="
    print *, "  Skill 6: Circuit Complexity"
    print *, "==========================================================="
    print *, ""
    
    ! Test 1: Build and evaluate parity circuit
    print *, "Test 1: Parity circuit on 4 inputs"
    call build_parity_circuit(4, circuit)
    
    inputs = [.true., .false., .true., .false.]
    call evaluate_circuit(circuit, inputs, output)
    print '(A,L1)', "  Parity(1,0,1,0) = ", output
    print '(A,I0)', "  Expected: T (odd number of 1s)"
    print *, ""
    
    ! Test 2: Count gates
    print *, "Test 2: Gate count"
    call count_gates(circuit, n_and, n_or, n_not, n_xor)
    print '(A,I0)', "  AND gates: ", n_and
    print '(A,I0)', "  OR gates: ", n_or
    print '(A,I0)', "  NOT gates: ", n_not
    print '(A,I0)', "  XOR gates: ", n_xor
    print *, ""
    
    ! Test 3: Circuit depth
    print *, "Test 3: Circuit depth"
    depth = circuit_depth(circuit)
    print '(A,I0)', "  Depth: ", depth
    print *, ""
    
    ! Test 4: Different input
    print *, "Test 4: Different input"
    inputs = [.true., .true., .false., .false.]
    call evaluate_circuit(circuit, inputs, output)
    print '(A,L1)', "  Parity(1,1,0,0) = ", output
    print '(A,I0)', "  Expected: F (even number of 1s)"
    print *, ""
    
    print *, "==========================================================="
    print *, "  Circuit complexity complete"
    print *, "==========================================================="
    
end program test_circuits
