from src.basics import *


class RandomValueFactory:
    """Static class. Helps to create unique random values"""

    @staticmethod
    def create(cls: type, unique: bool = True, *args, **kwargs) -> RandomValue:
        """
        :param args: args for cls.create()
        :param kwargs: kwargs for cls.create()
        :return: created instance of cls class
        """

        if unique:
            return cls.create_unique(cls, *args, **kwargs)

        return cls.create(*args, **kwargs)

    @staticmethod
    def create_address(unique: bool = True) -> Address:
        return RandomValueFactory.create(Address, unique=unique)

    @staticmethod
    def create_phone_number(unique: bool = True) -> PhoneNumber:
        return RandomValueFactory.create(PhoneNumber, unique=unique)

    @staticmethod
    def create_date(from_date: Date = None, unique: bool = True) -> Date:
        return RandomValueFactory.create(Date, unique=unique, from_date=from_date)

    @staticmethod
    def create_email(unique: bool = True) -> Email:
        return RandomValueFactory.create(Email, unique=unique)
