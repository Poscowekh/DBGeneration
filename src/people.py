from src.random_value_factory import *
from src.departments import Department


@dataclass(frozen=True)
class Person(RandomEntry):
    table_name: ClassVar[str] = "people"

    name: str
    phone_number: PhoneNumber
    email: Email

    # def __eq__(self, other):
    #     return self.name == other.name and \
    #            self.phone_number == other.phone_number

@dataclass(frozen=True)
class Customer(Person):
    __instances__: ClassVar[List[Person]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "customers"

    address: Address
    is_banned: bool

    def create(*args, **kwargs) -> Person:
        email: Email = None
        address: Address = None

        if rand_bool(3):
            email = RandomValueFactory.create_email()

        if rand_bool(3) or email is None:
            address = RandomValueFactory.create_address()

        return Customer(
            fake.name(),
            RandomValueFactory.create_phone_number(),
            email,
            address,
            not rand_bool(10)
        )


@dataclass
class NotBannedCustomer(GeneratedEntry):
    """Generated customer entry without is_banned flag"""

    entry: Customer


@dataclass(frozen=True)
class Manager(Person):
    __instances__: ClassVar[List[Person]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "managers"

    department_id: int
    position: str
    is_active: bool

    possible_positions: ClassVar[array_t] = array(
        ["Manager"] * 9 + # probability is 9/13
        ["Senior Manager"] * 3 + # probability is 3/13
        ["General Manager"], # probability is 1/13
        dtype=str)

    def create(*args, **kwargs) -> Person:
        return Manager(
            fake.name(),
            RandomValueFactory.create_phone_number(),
            RandomValueFactory.create_email(),
            Department.bounds(Department).random(),
            choice(Manager.possible_positions),
            rand_bool(3)
        )


@dataclass(frozen=True)
class Courier(Person):
    __instances__: ClassVar[List[Person]] = list()
    """List of known instances of this class"""

    table_name: ClassVar[str] = "couriers"

    is_active: bool

    def create(*args, **kwargs) -> Person:
        return Courier(
            fake.name(),
            RandomValueFactory.create_phone_number(),
            RandomValueFactory.create_email() if rand_bool(3) else None,
            rand_bool(3)
        )


@dataclass
class ActiveCourier(GeneratedEntry):
    """Courier entry with is_active flag set to True"""

    entry: Courier
    """The entry itself"""
