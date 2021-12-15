from typing import Dict, List, ClassVar
from dataclasses import dataclass
from abc import ABC, abstractmethod
from faker import Faker
from numpy.random import choice, randint
from numpy import array as nparray, dtype
from datetime import datetime, timedelta


fake = Faker(locale="ru_RU")


@dataclass(frozen=True)
class RandomValue(ABC):
    __instances__: ClassVar = list()

    @staticmethod
    @abstractmethod
    def create():
        pass

    @property
    @abstractmethod
    def string(self):
        pass

    @abstractmethod
    def tuplefy(self) -> Tuple:
        pass

    @staticmethod
    def exists(instance) -> bool:
        return instance in RandomValue.__instances__

    @staticmethod
    def register(instance) -> None:
        return RandomValue.__instances__.append(instance)

    def __str__(self) -> str:
        return self.string

    @staticmethod
    def get_instances() -> List[RandomValue]:
        return RandomValue.__instances__


@dataclass(frozen=True)
class Address(RandomValue):
    city: str
    street: str
    house: str
    postcode: str

    possible_cities: ClassVar = nparray([
        "г. Москва"
    ], dtype=str)

    @property
    def full_address(self) -> str:
        return ", ".join((self.city, self.street, self.house, self.postcode))

    def create() -> RandomValue:
        return Address(
            city=choice(Address.possible_cities),
            street=fake.street_name(),
            house=f"стр. {fake.building_number()}",
            postcode=fake.postcode()
        )

    def string(self):
        return self.full_address

    def tuplefy(self) -> Tuple:
        return (self.full_address,)


@dataclass(frozen=True)
class PhoneNumber(RandomValue):
    value: str

    def create() -> RandomValue:
        return PhoneNumber(fake.phone_number())

    def string(self):
        return self.value

    def tuplefy(self) -> Tuple:
        return (self.value,)


@dataclass(frozen=True)
class Date(RandomValue):
    value: datetime

    earliest_year: ClassVar = 2018

    def create(from_date: Date = None) -> RandomValue:
        if Date is None:
            return Date(fake.date_between(datetime(Date.earliest_year, 1, 1)))
        return Date(fake.date_between(datetime(from_date, 1, 1)))

    def string(self):
        return str(self.value)

    def tuplefy(self) -> Tuple:
        return (self.value,)


@dataclass(frozen=True)
class Email(RandomValue):
    value: str

    def create() -> RandomValue:
        return Email(fake.ascii_free_email())

    def string(self):
        return self.value

    def tuplefy(self) -> Tuple:
        return (self.value,)


def rand_bool(upper_bound: int = 1) -> bool:
    return False if randint(0, upper_bound) == 0 else True


def rand_from_bounds(bounds: Tuple[int, int]) -> int:
    return randint(bounds[0], bounds[1])


def none_or(any):
    return any if rand_bool() else None


clothing_types: Classvar = nparray([
    "PlaceholderClothingType"
], dtype=str)


defect_types: ClassVar = nparray([
    "PlaceholderDefectType"
], dtype=str)


@dataclass(frozen=True)
class RandomEntry(RandomValue):
    id: int

    latest_id: ClassVar = 0

    def string(self):
        return str(self.__dict__)

    def create(*args, **kwargs):
        pass
