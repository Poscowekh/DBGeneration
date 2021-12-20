from typing import Dict, List, Tuple, Union, ClassVar, Any, NamedTuple
from dataclasses import dataclass, astuple, field, fields, is_dataclass, Field
from collections import namedtuple
from abc import ABC, abstractmethod
from faker import Faker
from numpy.random import choice, randint, seed
from numpy import array, ndarray as array_t
from datetime import datetime, timedelta
from csv import writer


fake = Faker(locale="ru_RU")
"""Faker instance for email, address, date and name random generation"""


@dataclass(frozen=True)
class Bounds:
    """Interval of integers, including both bounds"""

    lower: int
    upper: int

    __true_upper__: int = field(init=False, repr=False, hash=False, compare=False)

    def __post_init__(self):
        super().__setattr__("__true_upper__", self.upper + 1)

    def count(self) -> int:
        return self.upper - self.lower + 1

    def random(self) -> int:
        return randint(self.lower, self.__true_upper__)

    def is_from(self, value: int) -> bool:
        return lower <= value <= upper

    @staticmethod
    def from_tuple(bounds: Tuple[int, int]) -> Any:
        if (bounds[0] > bounds[1]):
            raise ValueError("Bounds must be ordered left to right")

        return Bounds(bounds[0], bounds[1])

    def __str__(self) -> str:
        return f"[{self.lower}, {self.upper}]"


@dataclass(frozen=True)
class RandomValue(ABC):
    """Any basic data type"""

    __tuple__: Tuple = field(default=None, init=False, repr=False, compare=False, hash=False)
    """Tuple representation of the value"""

    __string__: str = field(default=None, init=False, repr=False, compare=False, hash=False)
    """String representation of the value"""

    @staticmethod
    def create_unique(cls: type, *args, **kwargs) -> Any:
        instance = cls.create(*args, **kwargs)

        while cls.exists(cls, instance):
            instance = cls.create(*args, **kwargs)

        cls.register(cls, instance)

        return instance

    @staticmethod
    @abstractmethod
    def create() -> Any:
        """Creates a random instance of a class without uniqueness checks"""
        pass

    @property
    def tuple(self) -> Tuple:
        """Converts RandomValue or RandomEntry instance into a SQL-friendly tuple"""

        if self.__tuple__ is None:
            result = []
            for field in fields(self): #type: Field
                if field.repr:
                    value = self.__dict__[field.name]
                    result.extend(value.tuple) if isinstance(value, RandomValue) else result.append(value)

            super().__setattr__("__tuple__", tuple(result))

        return self.__tuple__

    @property
    def string(self) -> str:
        """String representation of the instance. Uses tuple-representation"""

        if self.__string__ is None:
            super().__setattr__("__string__", str(self.tuple))

        return self.__string__

    def __str__(self) -> str:
        return self.string

    def __unicode__(self) -> str:
        return self.string

    def __repr__(self) -> str:
        return self.string

    @staticmethod
    def bounds(cls: type) -> Bounds:
        """ID bounds of known entry instances"""
        return Bounds(1, len(cls.__instances__))

    @staticmethod
    def exists(cls: type, instance: Any) -> bool:
        """Returns true if instance was registered"""
        return instance in cls.__instances__

    @staticmethod
    def register(cls: type, instance: Any) -> None:
        """Register a new instance of RandomValue or RandomEntry to save uniqeness"""
        return cls.__instances__.append(instance)

    @staticmethod
    def instances(cls: type) -> List[Any]:
        """Returns copy of the list of all known class instances"""
        return cls.__instances__

    @staticmethod
    def tuple_instances(cls: type) -> List[Tuple]:
        """Returns list of all known instances converted into sql-friendly tuples"""
        return [instance.tuple for instance in cls.__instances__]


@dataclass(frozen=True)
class Address(RandomValue):
    __instances__: ClassVar[List[RandomValue]] = list()
    """List of known instances of this class"""

    city: str = field(repr=None)
    street: str = field(repr=None)
    house: str = field(repr=None)
    postcode: str = field(repr=None)

    __full_address__: str = field(default=None, init=False)

    possible_cities: ClassVar[array_t] = array([
        "г. Москва"
    ], dtype=str)
    """Cities to use in generation"""

    def __post_init__(self):
        super().__setattr__("__full_address__", ", ".join((self.city, self.street, self.house, self.postcode)))

    def create() -> RandomValue:
        return Address(
            choice(Address.possible_cities),
            fake.street_name(),
            f"стр. {fake.building_number()}",
            fake.postcode()
        )

    @property
    def full_address(self) -> str:
        """United fields as should be included in sql value insertion"""
        return self.__full_address__

    @property
    def tuple(self) -> Tuple[str]:
        return (self.full_address,)

    @property
    def string(self) -> str:
        return self.full_address


@dataclass(frozen=True)
class PhoneNumber(RandomValue):
    __instances__: ClassVar[List[RandomValue]] = list()
    """List of known instances of this class"""

    value: str

    def create() -> RandomValue:
        return PhoneNumber(fake.phone_number())

    @property
    def string(self) -> str:
        return self.value


@dataclass(frozen=True)
class Date(RandomValue):
    __instances__: ClassVar[List[RandomValue]] = list()
    """List of known instances of this class"""

    value: datetime

    earliest_year: ClassVar[datetime] = datetime(2018, 1, 1)

    def create(**kwargs) -> RandomValue:
        from_date: Union[None, Date] = kwargs["from_date"] if kwargs is not None else None

        if from_date is None:
            return Date(fake.date_between(Date.earliest_year))
        elif isinstance(from_date, Date):
            return Date(fake.date_between(from_date.value))
        else:
            raise TypeError("from_date must be a Date instance or None")

    @property
    def string(self) -> str:
        return self.value

    def __add__(self, other) -> RandomValue:
        if not isinstance(other, timedelta):
            raise TypeError(f"Unsupported operand type(s) for +: 'Date' and '{type(other)}'")
        return Date(self.value + other)


@dataclass(frozen=True)
class Email(RandomValue):
    __instances__: ClassVar[List[RandomValue]] = list()
    """List of known instances of this class"""

    value: str

    def create() -> RandomValue:
        return Email(fake.ascii_free_email())

    @property
    def string(self) -> str:
        return self.value


def rand_bool(upper_bound: int = 1) -> bool:
    """
    Returns a random bool depending on upperbound.
    upper_bound is a multiplier to chance of getting True
    """

    # if upper_bound < 1:
    #     raise ValueError("upper_bound must be at least 1")

    return False if randint(0, upper_bound) == 0 else True


def none_or(any: Any) -> Union[None, Any]:
    return any if rand_bool() else None


clothing_types: array_t = array([
    "PlaceholderClothingType"
], dtype=str)


defect_types: array_t = array([
    "PlaceholderDefectType"
], dtype=str)


@dataclass(frozen=True)
class RandomEntry(RandomValue):
    """An actual record in table"""

    def create(*args, **kwargs) -> RandomValue:
        pass

    @staticmethod
    def to_csv(cls: type) -> None:
        path = f"data/{cls}.csv"
        header = ",".join([f.name for f in fields(cls)])

        with open(path, "w+") as f:
            handle = writer(f)
            handle.writerow(header)
            handle.writerows(cls.tuple_instances())


@dataclass
class GeneratedEntry(ABC):
    """Already generated entry that is useful for generation dependant entries"""

    id: int = field(hash=True)
    """Id of the entry. Is equal to the position it is in the instances list"""
    entry: RandomEntry = field(compare=False)
    """The entry itself"""
    is_used: bool = field(default=False, compare=False)
    """Flag that defines whether this entry was used for generation of some depending entry type"""

    @staticmethod
    def choose_unused(instances: List) -> Tuple[int, Any]:
        instance: GeneratedEntry = choice(instances)

        while instance.is_used:
            instance: GeneratedEntry = choice(instances)

        instance.is_used = True

        return instance.id, instance.entry
