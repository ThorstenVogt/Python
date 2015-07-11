
###   The purpose of this script is converting 835 messages in .x12 file format
###   to csv files.

    ### The general idea is to iterate through all files,
    ### then through all transaction sets,
    ### then through all claims,
    ### then through all service line items

    ### Data is collected into variables at each level,
    ### and is appended to a data array at the lowest.
    ### When all the iterations are finished, data is written to a
    ### csv file.



import os
import csv

### FUNCTIONS

def printfile(a):
    # this is a function for de-bugging
   f=open(a,"r")
   content=f.read()
   f.close()
   print content


def returnsegm(text,segmentcode):
    ## returns a particular segment in the input text
    segmentstart=text.find(segmentcode)
    segmentend=segmentstart+text[segmentstart:].find("~")
    return text[segmentstart:segmentend]

def returnelem(text,n):
    ## returns the nth element in input text
    elementcnt=text.count('*')
    if n<elementcnt:
        elementstart=text.replace('*', 'X', n-1).find('*')+1
        elementend=text.replace('*','X',n).find("*")
        return text[elementstart:elementend]
    elif n==elementcnt:
        elementstart=text.rfind("*")+1
        return text[elementstart:]
    else:
        return "error, no such element"

def returnelement(text,segcode,elemno):
    ## returns element number elemno out of the segment named segcode in the input text
    return returnelem(returnsegm(text,segcode),elemno)

   
def convdate(a):
    ## converts yyyymmdd to yyyy-mm-dd
   return a[0:4]+"-"+a[4:6]+"-"+a[6:8]

### VARIABLES

path = "D:/"  # where the .x12 files are stored.
n=0  # Counter

## This defines the columns for the csv file
data = [["TransactNo","filename","production date","NoinFile"]]


## Okay, let's go then

## iterate over all files in target directory:

listing = os.listdir(path)

for infile in listing:
   f=open(path+infile,"r")
   content=f.read()
   f.close

   ## Find and extract Production Date
   proddatepos=content.find("DTM*405*")
   proddate=convdate(content[proddatepos+8:proddatepos+16])

   ## Find number of transaction sets in file
   cnttransaction=content.count("ST*835*")

   ## Iterate over all transaction sets in file: ST to SE
   for i in range(1,cnttransaction+1):
          transactioninfile=i       
          
          transactpos=content.find("ST*835*"+str(i).zfill(4))
          
          if i < cnttransaction:
              nexttransactpos=content.find("ST*835*"+str(i+1).zfill(4))
              transact=content[transactpos:nexttransactpos]
          elif i == cnttransaction:
              transact=content[transactpos:]

          ## Find number of claims in transaction set
          cntclaim=transact.count("~CLP")

              
          ## Iterate over all claims in transaction set
          for j in range(1,cntclaim+1):
            claimintransaction=j
            if j<cntclaim:
               claimstart=transact.replace('~CLP', 'XXXX', j-1).find('~CLP')+1
               claimend=transact.replace('~CLP','XXXX',j).find("~CLP")
               claim=transact[claimstart:claimend]
            elif j==cntclaim:
               claimstart=transact.rfind("~CLP")+1
               claim=transact[claimstart:]
          
            ## Find number of service line items in claim
            cntitem=claim.count("~SVC")

            ## Iterate over all items in claim
            for k in range(1,cntitem+1):
               iteminclaim=k
               n=n+1
               if k<cntitem:
                   itemstart=claim.replace("~SVC", "XXXX", k-1).find("~SVC")+1
                   itemend=claim.replace("~SVC", "XXXX", k).find("~SVC")
                   item=claim[itemstart:itemend]
               elif k==cntitem:
                   itemstart=claim.rfind("~SVC")+1
                   item=claim[itemstart:]


                    ## data.append([n, infile, proddate, noinfile])



## write to csv file
b = open('result.csv', 'wb')
a = csv.writer(b)
a.writerows(data)
b.close()






     
