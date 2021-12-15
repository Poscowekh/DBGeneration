from basic_factory import BasicFactory
from facilities import Facility
from people import Customer


def addresses(count: int = 20):
    a = list()
    for i in range(count):
        a.append(Factory.create_address().string)
    printlns(*a)

def dates(count: int = 20):
    a = list()
    for i in range(count):
        a.append(Factory.create_date().string)
    printlns(*a)

def phone_numbers(count: int = 20):
    a = list()
    for i in range(count):
        a.append(Factory.create_phone_number().string)
    printlns(*a)

def departments(count: int = 20):
    a = list()
    for i in range(count):
        a.append(Facility.create().string())
    printlns(*a)

def customers(count: int = 20):
    a = list()
    for i in range(count):
        a.append(Customer.create().string())
    printlns(*a)

def printlns(*values: object):
    print(*values, sep="\n")


def main():
    #customers()


if __name__ == "__main__":
    main()

else:
    print("Not run as main")
    exit(1)
