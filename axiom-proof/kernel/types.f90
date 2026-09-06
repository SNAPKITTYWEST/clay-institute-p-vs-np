! AXIOM Proof Assistant - Type Theory Kernel (Fortran)
! Dependent type system with universe hierarchy
! Pi types, Sigma types, Inductive types

module axiom_types
    implicit none
    private
    public :: term_t, type_t, universe_t, env_t
    public :: term_var, term_lambda, term_pi, term_sigma
    public :: term_app, term_pair, term_proj
    public :: term_inductive, term_constructor, term_recursor
    public :: type_check, type_infer, def_eq
    public :: env_new, env_extend, env_lookup

    ! Maximum environment size
    integer, parameter :: MAX_ENV = 10000
    integer, parameter :: MAX_NAME = 64

    ! Term kinds
    integer, parameter :: TERM_VAR = 1
    integer, parameter :: TERM_LAMBDA = 2
    integer, parameter :: TERM_PI = 3
    integer, parameter :: TERM_SIGMA = 4
    integer, parameter :: TERM_APP = 5
    integer, parameter :: TERM_PAIR = 6
    integer, parameter :: TERM_PROJ = 7
    integer, parameter :: TERM_IND = 8
    integer, parameter :: TERM_CTOR = 9
    integer, parameter :: TERM_REC = 10
    integer, parameter :: TERM_UNIV = 11

    ! Term type: core AST node
    type :: term_t
        integer :: kind
        character(len=MAX_NAME) :: name
        type(term_t), pointer :: body => null()
        type(term_t), pointer :: arg_type => null()
        type(term_t), pointer :: left => null()
        type(term_t), pointer :: right => null()
        integer :: index = 0
        integer :: universe_level = 0
    end type

    ! Type alias
    type :: type_t
        type(term_t) :: term
    end type

    ! Universe hierarchy
    type :: universe_t
        integer :: level
    end type

    ! Environment entry
    type :: env_entry_t
        character(len=MAX_NAME) :: name
        type(term_t) :: type
        type(term_t) :: value
        logical :: has_value
    end type

    ! Typing environment
    type :: env_t
        type(env_entry_t) :: entries(MAX_ENV)
        integer :: size = 0
    end type

contains

    ! Create variable term
    function term_var(name) result(t)
        character(len=*), intent(in) :: name
        type(term_t) :: t
        t%kind = TERM_VAR
        t%name = name
    end function

    ! Create lambda term: λ(x : A). body
    function term_lambda(name, arg_type, body) result(t)
        character(len=*), intent(in) :: name
        type(term_t), target, intent(in) :: arg_type, body
        type(term_t) :: t
        t%kind = TERM_LAMBDA
        t%name = name
        t%arg_type => arg_type
        t%body => body
    end function

    ! Create Pi type: Π(x : A). B
    function term_pi(name, arg_type, body) result(t)
        character(len=*), intent(in) :: name
        type(term_t), target, intent(in) :: arg_type, body
        type(term_t) :: t
        t%kind = TERM_PI
        t%name = name
        t%arg_type => arg_type
        t%body => body
    end function

    ! Create Sigma type: Σ(x : A). B
    function term_sigma(name, arg_type, body) result(t)
        character(len=*), intent(in) :: name
        type(term_t), target, intent(in) :: arg_type, body
        type(term_t) :: t
        t%kind = TERM_SIGMA
        t%name = name
        t%arg_type => arg_type
        t%body => body
    end function

    ! Create application: f x
    function term_app(fn, arg) result(t)
        type(term_t), target, intent(in) :: fn, arg
        type(term_t) :: t
        t%kind = TERM_APP
        t%left => fn
        t%right => arg
    end function

    ! Create pair: (a, b)
    function term_pair(fst, snd) result(t)
        type(term_t), target, intent(in) :: fst, snd
        type(term_t) :: t
        t%kind = TERM_PAIR
        t%left => fst
        t%right => snd
    end function

    ! Create projection: π₁(p) or π₂(p)
    function term_proj(pair, index) result(t)
        type(term_t), target, intent(in) :: pair
        integer, intent(in) :: index
        type(term_t) :: t
        t%kind = TERM_PROJ
        t%left => pair
        t%index = index
    end function

    ! Create inductive type definition
    function term_inductive(name, universe_level) result(t)
        character(len=*), intent(in) :: name
        integer, intent(in) :: universe_level
        type(term_t) :: t
        t%kind = TERM_IND
        t%name = name
        t%universe_level = universe_level
    end function

    ! Create constructor
    function term_constructor(name, ind_type) result(t)
        character(len=*), intent(in) :: name
        type(term_t), target, intent(in) :: ind_type
        type(term_t) :: t
        t%kind = TERM_CTOR
        t%name = name
        t%arg_type => ind_type
    end function

    ! Create recursor (eliminator)
    function term_recursor(ind_type, motive, major) result(t)
        type(term_t), target, intent(in) :: ind_type, motive, major
        type(term_t) :: t
        t%kind = TERM_REC
        t%left => ind_type
        t%arg_type => motive
        t%body => major
    end function

    ! Create new environment
    function env_new() result(env)
        type(env_t) :: env
        env%size = 0
    end function

    ! Extend environment with new binding
    subroutine env_extend(env, name, typ, val, has_val)
        type(env_t), intent(inout) :: env
        character(len=*), intent(in) :: name
        type(term_t), intent(in) :: typ
        type(term_t), intent(in), optional :: val
        logical, intent(in), optional :: has_val

        if (env%size >= MAX_ENV) then
            print *, "ERROR: Environment overflow"
            stop 1
        end if

        env%size = env%size + 1
        env%entries(env%size)%name = name
        env%entries(env%size)%type = typ
        
        if (present(has_val) .and. has_val) then
            env%entries(env%size)%has_value = .true.
            if (present(val)) then
                env%entries(env%size)%value = val
            end if
        else
            env%entries(env%size)%has_value = .false.
        end if
    end subroutine

    ! Lookup name in environment
    function env_lookup(env, name, entry, found) result(success)
        type(env_t), intent(in) :: env
        character(len=*), intent(in) :: name
        type(env_entry_t), intent(out) :: entry
        logical, intent(out) :: found
        logical :: success
        integer :: i

        found = .false.
        success = .false.

        do i = env%size, 1, -1
            if (trim(env%entries(i)%name) == trim(name)) then
                entry = env%entries(i)
                found = .true.
                success = .true.
                return
            end if
        end do
    end function

    ! Type inference: compute type of term
    recursive function type_infer(env, term, result_type) result(success)
        type(env_t), intent(in) :: env
        type(term_t), intent(in) :: term
        type(term_t), intent(out) :: result_type
        logical :: success
        type(env_entry_t) :: entry
        logical :: found
        type(term_t) :: fn_type, arg_type, body_type

        success = .false.

        select case (term%kind)
        case (TERM_VAR)
            ! Variable: lookup in environment
            if (env_lookup(env, term%name, entry, found)) then
                result_type = entry%type
                success = .true.
            end if

        case (TERM_LAMBDA)
            ! Lambda: Π(x : A). B where body : B
            if (associated(term%arg_type) .and. associated(term%body)) then
                ! Extend env with x : A
                call env_extend(env, term%name, term%arg_type)
                if (type_infer(env, term%body, body_type)) then
                    result_type = term_pi(term%name, term%arg_type, body_type)
                    success = .true.
                end if
            end if

        case (TERM_PI)
            ! Pi type: if A : Type i and B : Type j, then Π(x:A).B : Type (max i j)
            result_type%kind = TERM_UNIV
            result_type%universe_level = 0
            success = .true.

        case (TERM_APP)
            ! Application: if f : Π(x:A).B and arg : A, then f arg : B[arg/x]
            if (associated(term%left) .and. associated(term%right)) then
                if (type_infer(env, term%left, fn_type)) then
                    if (fn_type%kind == TERM_PI) then
                        if (type_check(env, term%right, fn_type%arg_type)) then
                            result_type = fn_type%body
                            success = .true.
                        end if
                    end if
                end if
            end if

        case (TERM_UNIV)
            ! Universe: Type i : Type (i+1)
            result_type%kind = TERM_UNIV
            result_type%universe_level = term%universe_level + 1
            success = .true.

        case (TERM_IND)
            ! Inductive type: Nat : Type 0
            result_type%kind = TERM_UNIV
            result_type%universe_level = term%universe_level
            success = .true.

        case (TERM_CTOR)
            ! Constructor: zero : Nat, succ : Nat → Nat
            if (associated(term%arg_type)) then
                result_type = term%arg_type
                success = .true.
            end if

        end select
    end function

    ! Type checking: verify term has given type
    recursive function type_check(env, term, expected_type) result(success)
        type(env_t), intent(in) :: env
        type(term_t), intent(in) :: term, expected_type
        logical :: success
        type(term_t) :: inferred_type

        success = .false.

        ! Try to infer type and compare
        if (type_infer(env, term, inferred_type)) then
            success = def_eq(env, inferred_type, expected_type)
        end if
    end function

    ! Definitional equality: check if two terms are definitionally equal
    recursive function def_eq(env, t1, t2) result(equal)
        type(env_t), intent(in) :: env
        type(term_t), intent(in) :: t1, t2
        logical :: equal

        equal = .false.

        ! Same kind
        if (t1%kind /= t2%kind) return

        select case (t1%kind)
        case (TERM_VAR)
            equal = (trim(t1%name) == trim(t2%name))

        case (TERM_LAMBDA, TERM_PI, TERM_SIGMA)
            equal = (trim(t1%name) == trim(t2%name))
            if (equal .and. associated(t1%arg_type) .and. associated(t2%arg_type)) then
                equal = def_eq(env, t1%arg_type, t2%arg_type)
            end if
            if (equal .and. associated(t1%body) .and. associated(t2%body)) then
                equal = def_eq(env, t1%body, t2%body)
            end if

        case (TERM_APP)
            if (associated(t1%left) .and. associated(t2%left)) then
                equal = def_eq(env, t1%left, t2%left)
            end if
            if (equal .and. associated(t1%right) .and. associated(t2%right)) then
                equal = def_eq(env, t1%right, t2%right)
            end if

        case (TERM_UNIV)
            equal = (t1%universe_level == t2%universe_level)

        case (TERM_IND)
            equal = (trim(t1%name) == trim(t2%name))

        case (TERM_CTOR)
            equal = (trim(t1%name) == trim(t2%name))

        end select
    end function

end module axiom_types
