PROC IMPORT OUT= WORK.imputation
            DATAFILE= "C:\Users\jjansson\Documents\GitHub\HIVBackProjection\Imputation\Data\notifications2014-3-exposureDOBreplaced.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="Sheet1"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data imputation_sqr;
set imputation;
cd4_sqrt=sqrt(cd4count );
age=datehivdec-yearbirthdec; 
run;



proc glm data = imputation_sqr;
class state sex exp;
model cd4_sqrt=age sex datehivdec  exp/intercept solution;
output out=A h=hii residual=raw student=standard rstudent=student predicted=fit;
run;


/*Conduct MCMC multiple imputation*/
proc mi data=imputation_sqr seed=42037921
nimpute=5 out=miout2;
mcmc;
var sex datehivdec exp age cd4_sqrt ;
run;

data miout2;
set miout2;
/* change the CD4 sqrt to a CD4 count*/
cd4base= cd4_sqrt**2;	
yearbirth=floor(datehivdec-age);
run;

DATA subset;
  SET work.miout2;
IF _Imputation_ = 1;

PROC EXPORT DATA= WORK.subset OUTFILE= "C:\Users\jjansson\Documents\GitHub\HIVBackProjection\Imputation\Data\notifications2014imputation.xls" DBMS=XLS REPLACE;
SHEET="Dataset_1";
RUN;




