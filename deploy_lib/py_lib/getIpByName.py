import sys
from databaseFunctions import get_ip_by_name

def return_ip_by_name(ip):
    get_ip_by_name(ip)

if __name__== "__main__":
    return_ip_by_name(sys.argv[1])