from basic_factory import *


@dataclass(frozen=True)
class Person(RandomEntry):
    name: str
    phone_number: PhoneNumber


@dataclass(frozen=True)
class Customer(Person):
    email: Email
    address: Address
    is_banned: bool

    def create(*args, **kwargs) -> Person:
        id = Customer.latest_id
        Customer.latest_id += 1

        return Customer(
            id,
            fake.name(),
            BasicFactory.create_phone_number(),
            BasicFactory.create_email(),
            BasicFactory.create_address(),
            False # rand_bool()
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.name) + \
               self.phone_number.tuplefy() + \
               self.email.tuplefy() + \
               self.address.tuplefy() + \
               (self.is_banned,)


@dataclass(frozen=True)
class Manager(Person):
    department_id: int
    email: Email
    position: str

    possible_positions: ClassVar = nparray(
        ["Manager"] * 9 + # probability is 9/13
        ["Senior Manager"] * 3 + # probability is 3/13
        ["General Manager"], # probability is 1/13
        dtype=str)

    def create(department_id_bounds: Tuple[int, int], *args, **kwargs) -> Person:
        id = Manager.latest_id
        Manager.latest_id += 1

        return Manager(
            id,
            fake.name(),
            BasicFactory.create_phone_number(),
            rand_from_bounds(department_id_bounds),
            BasicFactory.create_email(),
            choice(Manager.possible_positions)
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.department_id,
                self.name,
                self.position) + \
               self.phone_number.tuplefy() + \
               self.email.tuplefy()


@dataclass(frozen=True)
class Courier(Person):
    is_active: bool

    def create(*args, **kwargs) -> Person:
        id = Courier.latest_id
        Courier.latest_id += 1

        return Courier(
            id,
            fake.name(),
            BasicFactory.create_phone_number(),
            True # rand_bool()
        )

    def tuplefy(self) -> Tuple:
        return (self.id,
                self.name) + \
               self.phone_number.tuplefy() + \
               (self.is_active,)
