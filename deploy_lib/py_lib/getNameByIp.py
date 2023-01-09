import sys
from databaseFunctions import get_name_by_ip

def return_name_by_ip(ip):
    get_name_by_ip(ip)

if __name__== "__main__":
    return_name_by_ip(sys.argv[1])