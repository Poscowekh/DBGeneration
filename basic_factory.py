from randomizer import *


class BasicFactory:
    @staticmethod
    def create(cls: RandomValue, *args, **kwargs) -> RandomValue:
        result = cls.create()

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
    def create_date(from_date: Date = None) -> Date:
        return BasicFactory.create(Date, from_date)

    @staticmethod
    def create_email() -> Email:
        return BasicFactory.create(Email)
