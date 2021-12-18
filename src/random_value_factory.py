from src.basics import *


class BasicFactory:
    """
    Helps to create unique random values
    """

    @staticmethod
    def create(cls: type, unique: bool = True, *args, **kwargs) -> RandomValue:
        """
        :param args: args for cls.create()
        :param kwargs: kwargs for cls.create()
        :return: created instance of cls class
        """

        result = cls.create()

        if unique:
            while cls.exists(result):
                result = cls.create(*args, **kwargs)

        cls.register(result)

        return result

    @staticmethod
    def create_address() -> Address:
        return BasicFactory.create(Address)

    @staticmethod
    def create_phone_number() -> PhoneNumber:
        return BasicFactory.create(PhoneNumber)

    @staticmethod
    def create_date(unique: bool = True, from_date: Date = None) -> Date:
        return BasicFactory.create(Date, from_date)

    @staticmethod
    def create_email() -> Email:
        return BasicFactory.create(Email)
