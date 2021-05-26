import sys

fileName1= sys.argv[1]
fileName2= sys.argv[2]

with open(fileName1,"r") as f1:
    c1 = f1.read()
with open(fileName2,"r") as f2:
    c2 = f2.read()

print(c1==c2)
