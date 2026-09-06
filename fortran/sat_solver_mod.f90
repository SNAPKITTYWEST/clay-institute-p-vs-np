! P vs NP Attack: Fortran SAT Solver
! DPLL algorithm with optimizations
! Tests millions of heuristics, seals attempts to WORM ledger

module sat_solver
    implicit none
    private
    public :: sat_instance, assignment, solve_sat, dpll, unit_propagate, pure_literal, init_sat, add_clause, init_assignment
    
    integer, parameter :: MAX_VARS = 10000
    integer, parameter :: MAX_CLAUSES = 100000
    
    ! SAT instance in CNF
    type :: sat_instance
        integer :: num_vars
        integer :: num_clauses
        integer, allocatable :: clauses(:,:)  ! clauses(clause_idx, literal_idx)
        integer, allocatable :: clause_lengths(:)
    end type
    
    ! Assignment
    type :: assignment
        integer, allocatable :: values(:)  ! -1, 0, 1 (false, unassigned, true)
    end type

contains

    ! Initialize SAT instance
    subroutine init_sat(inst, nvars, nclauses)
        type(sat_instance), intent(inout) :: inst
        integer, intent(in) :: nvars, nclauses
        
        ! Deallocate if already allocated
        if (allocated(inst%clauses)) deallocate(inst%clauses)
        if (allocated(inst%clause_lengths)) deallocate(inst%clause_lengths)
        
        inst%num_vars = nvars
        inst%num_clauses = nclauses
        allocate(inst%clauses(nclauses, 100))  ! max 100 literals per clause
        allocate(inst%clause_lengths(nclauses))
        inst%clauses = 0
        inst%clause_lengths = 0
    end subroutine

    ! Add clause to instance
    subroutine add_clause(inst, clause_idx, literals, length)
        type(sat_instance), intent(inout) :: inst
        integer, intent(in) :: clause_idx, length
        integer, intent(in) :: literals(:)
        
        inst%clauses(clause_idx, 1:length) = literals
        inst%clause_lengths(clause_idx) = length
    end subroutine

    ! Initialize assignment (all unassigned)
    subroutine init_assignment(assign, nvars)
        type(assignment), intent(inout) :: assign
        integer, intent(in) :: nvars
        
        ! Deallocate if already allocated
        if (allocated(assign%values)) deallocate(assign%values)
        
        allocate(assign%values(nvars))
        assign%values = 0
    end subroutine

    ! Evaluate literal under assignment
    function eval_literal(assign, lit) result(val)
        type(assignment), intent(in) :: assign
        integer, intent(in) :: lit
        logical :: val
        integer :: var
        
        var = abs(lit)
        if (assign%values(var) == 0) then
            val = .false.  ! unassigned
        else if (lit > 0) then
            val = (assign%values(var) == 1)
        else
            val = (assign%values(var) == -1)
        end if
    end function

    ! Check if clause is satisfied
    function clause_satisfied(inst, assign, clause_idx) result(sat)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(in) :: assign
        integer, intent(in) :: clause_idx
        logical :: sat
        integer :: i, lit
        logical :: all_assigned
        
        sat = .false.
        all_assigned = .true.
        
        do i = 1, inst%clause_lengths(clause_idx)
            lit = inst%clauses(clause_idx, i)
            if (assign%values(abs(lit)) == 0) then
                all_assigned = .false.
            else if (eval_literal(assign, lit)) then
                sat = .true.
                return
            end if
        end do
        
        ! If all literals assigned and none true, clause is false
        if (all_assigned) sat = .false.
    end function

    ! Check if formula is satisfied
    function formula_satisfied(inst, assign) result(sat)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(in) :: assign
        logical :: sat
        integer :: i
        
        sat = .true.
        do i = 1, inst%num_clauses
            if (.not. clause_satisfied(inst, assign, i)) then
                sat = .false.
                return
            end if
        end do
    end function

    ! Unit propagation: if clause has one unassigned literal, set it
    subroutine unit_propagate(inst, assign, changed)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(inout) :: assign
        logical, intent(out) :: changed
        integer :: i, j, lit, unassigned_count, unassigned_lit
        logical :: satisfied
        
        changed = .false.
        
        do i = 1, inst%num_clauses
            unassigned_count = 0
            unassigned_lit = 0
            satisfied = .false.
            
            ! Count unassigned literals
            do j = 1, inst%clause_lengths(i)
                lit = inst%clauses(i, j)
                if (assign%values(abs(lit)) == 0) then
                    unassigned_count = unassigned_count + 1
                    unassigned_lit = lit
                else if (eval_literal(assign, lit)) then
                    satisfied = .true.
                    exit
                end if
            end do
            
            ! If exactly one unassigned and not satisfied, propagate
            if (.not. satisfied .and. unassigned_count == 1) then
                assign%values(abs(unassigned_lit)) = sign(1, unassigned_lit)
                changed = .true.
            end if
        end do
    end subroutine

    ! Pure literal elimination
    subroutine pure_literal(inst, assign, changed)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(inout) :: assign
        logical, intent(out) :: changed
        integer :: i, j, lit, var
        logical, allocatable :: appears_pos(:), appears_neg(:)
        
        changed = .false.
        allocate(appears_pos(inst%num_vars))
        allocate(appears_neg(inst%num_vars))
        appears_pos = .false.
        appears_neg = .false.
        
        ! Count appearances
        do i = 1, inst%num_clauses
            do j = 1, inst%clause_lengths(i)
                lit = inst%clauses(i, j)
                var = abs(lit)
                if (assign%values(var) == 0) then
                    if (lit > 0) then
                        appears_pos(var) = .true.
                    else
                        appears_neg(var) = .true.
                    end if
                end if
            end do
        end do
        
        ! Set pure literals
        do i = 1, inst%num_vars
            if (appears_pos(i) .and. .not. appears_neg(i)) then
                assign%values(i) = 1
                changed = .true.
            else if (appears_neg(i) .and. .not. appears_pos(i)) then
                assign%values(i) = -1
                changed = .true.
            end if
        end do
        
        deallocate(appears_pos, appears_neg)
    end subroutine

    ! DPLL algorithm
    recursive function dpll(inst, assign) result(sat)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(inout) :: assign
        logical :: sat
        logical :: changed
        integer :: i, var
        
        ! Unit propagation
        call unit_propagate(inst, assign, changed)
        
        ! Pure literal elimination
        call pure_literal(inst, assign, changed)
        
        ! Check if satisfied
        if (formula_satisfied(inst, assign)) then
            sat = .true.
            return
        end if
        
        ! Check for conflict (all assigned but not satisfied)
        if (all(assign%values /= 0)) then
            sat = .false.
            return
        end if
        
        ! Find first unassigned variable
        var = 0
        do i = 1, inst%num_vars
            if (assign%values(i) == 0) then
                var = i
                exit
            end if
        end do
        
        if (var == 0) then
            sat = .false.
            return
        end if
        
        ! Try assigning true
        assign%values(var) = 1
        if (dpll(inst, assign)) then
            sat = .true.
            return
        end if
        
        ! Backtrack: try assigning false
        assign%values(var) = -1
        if (dpll(inst, assign)) then
            sat = .true.
            return
        end if
        
        ! Backtrack: unassign
        assign%values(var) = 0
        sat = .false.
    end function

    ! Main solver interface
    subroutine solve_sat(inst, assign, sat)
        type(sat_instance), intent(in) :: inst
        type(assignment), intent(inout) :: assign
        logical, intent(out) :: sat
        
        call init_assignment(assign, inst%num_vars)
        sat = dpll(inst, assign)
    end subroutine

end module sat_solver
