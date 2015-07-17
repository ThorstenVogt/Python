
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
    if text=='' or text==None:
        return ''
    elif n<elementcnt:
        elementstart=text.replace('*', 'X', n-1).find('*')+1
        elementend=text.replace('*','X',n).find("*")
        return text[elementstart:elementend]
    elif n==elementcnt:
        elementstart=text.rfind("*")+1
        return text[elementstart:]


def returnelement(text,segcode,elemno):
    ## returns element number elemno out of the segment named segcode in the input text
    return returnelem(returnsegm(text,segcode),elemno)

def returnsubelement(text,number):
   ## returns a subelement (colon separated) out of text
   subcnt=text.count(':')+1
   if subcnt==1 and number>1:
      return ''
   elif number<subcnt:
      if number==1:
         substart=0
         subend=text.find(':')
      elif number > 1:
         substart=text.replace(':', 'X', number-2).find(':')+1
         subend=text.replace(':','X',number-1).find(':')
      return text[substart:subend]
   elif number==subcnt:
      substart=text.rfind(':')+1
      return text[substart:]
   else:
      return ''


   
def convdate(a):
    ## converts yyyymmdd to yyyy-mm-dd
   if a==None:
      return ""
   else:
      return a[0:4]+"-"+a[4:6]+"-"+a[6:8]

### VARIABLES

path = "C:/TestData/"  # where the .x12 files are stored.
n=0  # Counter

data=[]

## This defines the columns for the csv file
datastructure = [
"Transact No","Filename","Prod Date"		        		## 0-2		TRN*: 2   FILENAME, DTM*405
,"Pat Ctrl No","Payer Clm No","Line Item No"		        	## 3-5		CLP*: 1,7   REF*6R*:  3
,"Payer Nm", "Payer Id", "Payer City", "Payer State","Crossover Payer"	## 6-10		N1*PR*:  2,4  N4*: 1,2  NM1*TT:  3
,"Product Type",''							## 11-12	REF*CE*:   2
,"Payee Nm", "Payee id", "Payee City", "Payee State"			## 13-16	N1*PE*:  2,4  N4*: 1,2
,"Pat Last Nm","Pat First Nm","Pat Mid Init","Pat Id"            	## 17-20	NM1*QC*: 3,4,5,9
,"Prov Last Nm","Prov First Nm","Prov Mid Init", "Prov Id"        	## 21-24	NM1*82*: 3,4,5,9
,"Srv Date","Srv Code","Srv Cd Mod1","Srv Cd Mod2"			## 25-28	DTM*472: 2  SVC* 1 seg 2
,"Amt chrgd", "Clm Date"						## 29-30	SVC* 2      DTM*050* 2
,"Amt paid", "Pmt Date"	        					## 31-32	SCV* 3      BPR*:    16
,"CA Grp 1","CA Rsn 1","CA Amt 1"				        ## 33-35	CAS* 1,2,3
,"CA Grp 2","CA Rsn 2","CA Amt 2"				        ## 36-38	
,"CA Grp 3","CA Rsn 3","CA Amt 3"				        ## 39-41	
,"CA Grp 4","CA Rsn 4","CA Amt 4"				        ## 42-44	
,"CA Grp 5","CA Rsn 5","CA Amt 5"				        ## 45-47	
,"CA Grp 6","CA Rsn 6","CA Amt 6"				        ## 48-50
,"Clm Chrg","Clm Pmt", "Clm Pat"]					## 51-53	CLP 3,4,5


   
      ## add datarow to data
data.append(datastructure)


## this is the intermediate storage where data is collected for each line item
datarow=['']*54




## Okay, let's go then

## iterate over all files in target directory:

listing = os.listdir(path)

for infile in listing:

   ## Save Filename 
   datarow[1]=infile 

   f=open(path+infile,"r")
   content=f.read()
   f.close


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

           ## Extract Transaction No - same as check or EFT no
           datarow[0]=returnelement(transact,"TRN",2)

           ## Extract Production Date
           proddatepos=content.find("DTM*405*")
           datarow[2]=convdate(content[proddatepos+8:proddatepos+16])
           
           ## Extract Payer Information
           datarow[6]=returnelement(transact,"N1*PR*",2)
           datarow[7]=returnelement(transact,"N1*PR*",4)
           datarow[8]=returnelement(transact,"N4*",1)
           datarow[9]=returnelement(transact,"N4*",2)
           
           ## Extract Payee Information
           datarow[13]=returnelement(transact,"N1*PE*",2)
           datarow[14]=returnelement(transact,"N1*PE*",4)

           ## Extract Payment Date 
           datarow[32]=convdate(returnelement(transact,"BPR*",16))
           
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

            ## Extract Patient and Payer Claim Number
            datarow[3]=returnelement(claim,"CLP",1)
            datarow[4]=returnelement(claim,"CLP",7)

            ## Extract Patient Info
            datarow[17]=returnelement(claim,"NM1*QC*",3)
            datarow[18]=returnelement(claim,"NM1*QC*",4)
            datarow[19]=returnelement(claim,"NM1*QC*",5)
            datarow[20]=returnelement(claim,"NM1*QC*",9)
            
            ## Extract Provider Info
            datarow[21]=returnelement(claim,"NM1*82*",3)
            datarow[22]=returnelement(claim,"NM1*82*",4)
            datarow[23]=returnelement(claim,"NM1*82*",5)
            datarow[24]=returnelement(claim,"NM1*82*",9)

            ## Extract Crossover Carrier
            datarow[25]=returnelement(claim,"NM1*TT*",3)

            ## Extract Product Type
            datarow[11]=returnelement(claim,"REF*CE*",2)

            ## Extract Claim Payment Info
            datarow[51]=returnelement(claim,"CLP",3)
            datarow[52]=returnelement(claim,"CLP",4)
            datarow[53]=returnelement(claim,"CLP",5)

            
            ## Extract Claim Date
            datarow[30]=convdate(returnelement(claim,"DTM*050*",2))
          
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


                ## Extract Service Line Item Number
                datarow[5]=str(returnelement(item,"REF*6R*",2))

                ## Extract Service Date
                datarow[25]=convdate(returnelement(item,"DTM*472*",2))
                ## Extract Service Code & Code Modifiers
                datarow[26]=returnsubelement((returnelement(item,"SVC*",1)[3:]),1)
                datarow[27]=returnsubelement((returnelement(item,"SVC*",1)[3:]),2)
                datarow[28]=returnsubelement((returnelement(item,"SVC*",1)[3:]),3)

                ## Extract Amount Charged
                datarow[29]=returnelement(item,"SVC*",2)

                ## Extract Amount Paid
                datarow[31]=returnelement(item,"SVC*",3)

                ## Find number of claim adjustments for each item (max 6)
                cntadj=item.count("~CAS")

                
                ## Iterate over all claim adjustment CAS for each item
                for l in range(0,6):
                    
                    if l<cntadj-1:
                        adjstart=item.replace("~CAS", "XXXX", l).find("~CAS")+1
                        adjend=item.replace("~CAS", "XXXX", l+1).find("~CAS")
                        adj=item[adjstart:adjend]
                    elif l==cntadj-1:
                        adjstart=item.replace("~CAS", "XXXX", l).find("~CAS")+1
                        adjhelp=item[adjstart:]
                        adj=adjhelp[:(adjhelp.find("~"))]    ## <-- careful, following element varies, so only the ~-sign as terminator!
                    elif l>=cntadj:
                        adj=''
                        

                    ## Extract data for claim adjustment
                        
                    ## Extract CA Group Code
                    datarow[33+l*3]=returnelem(adj,1)
                    ## Extract CA Reason Code
                    datarow[34+l*3]=returnelem(adj,2)
                    ## Extract CA Amount
                    datarow[35+l*3]=returnelem(adj,3)   

                    
                ## add string to data
                update=datarow[:]
                data.append(update)
                
                



## write to csv file
b = open('result.csv', 'wb')
a = csv.writer(b)
a.writerows(data)
b.close()

print "done."




     
