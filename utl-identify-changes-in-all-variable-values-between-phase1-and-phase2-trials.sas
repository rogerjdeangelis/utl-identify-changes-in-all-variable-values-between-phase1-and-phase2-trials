%let pgm=utl-identify-changes-in-all-variable-values-between-phase1-and-phase2-trials;

%stop_submission;

Identify changes in all variable values between phase1 and phase2 trials;


   CONTENTS

       1 sas sql
       1 sas sql arrays
       2 r sql
       3 python sql
       4 excel sql

github
https://tinyurl.com/4e6yaap8
https://github.com/rogerjdeangelis/utl-identify-changes-in-all-variable-values-between-phase1-and-phase2-trials

related to
https://tinyurl.com/bdfczexy
https://communities.sas.com/t5/SAS-Programming/comparing-all-variable-values-between-two-datasets-and-high/m-p/843094#M333349


/**************************************************************************************************************************/
/* THIS IS WHAT WE WANT                                                                                                   */
/*                                                                                                                        */
/*  PATIENT   ADVERSE EVENT              DOSED              DRUG CHANGE        CHANGES BETWEEN PHASE1 & PHASE2            */
/*  VISIT    ==================      ===============     ==================    ==============================+            */
/*           PHASE1      PHASE2      PHASE1    PHASE2    PHASE1      PHASE2                                               */
/*  KEY      EVTOLD      EVTNEW      STYOLD    STYNEW    DRGOLD      DRGNEW     EVENT      STUDY        DRG               */
/*                                                                                                                        */
/* 101231    asthma      asthma       Yes       Yes      parace      parace    MATCHING    MATCHING   MATCHING            */
/* 101232    acidity     acidity      No        Yes      drg1        drg1      MATCHING    NO MATCH   MATCHING            */
/* 102321    asthma      asthma       Yes       Yes      sinarest              MATCHING    MATCHING   NO MATCH            */
/* 103431    vomit       vomit        Yes       Yes      drg5        drg4      MATCHING    MATCHING   NO MATCH            */
/* 103432    fever       pain         No        No       drg5        drg5      NO MATCH    MATCHING   MATCHING            */
/* 103433    pain                     Yes                drg4                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 103434                pan                    No                   drg5      P2 ONLY     P2 ONLY    P2 ONLY             */
/* 104201                fever                  Yes                  drg6      P2 ONLY     P2 ONLY    P2 ONLY             */
/* 104202    pain        pain         No        No       drg5        drg5      MATCHING    MATCHING   MATCHING            */
/* 104203                headache               No                   drg1      P2 ONLY     P2 ONLY    P2 ONLY             */
/* 104204    pain                     No                 drg1                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104206    fever                    No                 drg6                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104207    headache                 No                 5rg1                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104208    pain                     yes                drg3                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104233    headache                 Yes                drg3                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104235    headache                 No                 drg1                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 104431    vomit                    Yes                drg4                  P1 ONLY     P1 ONLY    P1 ONLY             */
/* 107433                pain                   No                   drg5      P2 ONLY     P2 ONLY    P2 ONLY             */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
       _ |_|                _
 _ __ | |__   __ _ ___  ___/ |
| `_ \| `_ \ / _` / __|/ _ \ |
| |_) | | | | (_| \__ \  __/ |
| .__/|_| |_|\__,_|___/\___|_|
|_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";

data sd1.phase1;
length key $8.;
input PID$ AGE$ Visit$ phase$ event$ drg$ study$;
key=cats(PID, AGE, Visit);
keep key drg event study;
cards4;;;;
101 23 1 1 asthma parace Yes
102 32 1 1 asthma sinarest Yes
101 23 2 1 acidity drg1 No
103 43 1 1 vomit drg5 Yes
103 43 2 1 fever drg5 No
103 43 3 1 pain drg4 Yes
104 20 6 1 fever drg6 No
104 20 7 1 headache 5rg1 No
104 20 8 1 pain drg3 yes
104 23 3 1 headache drg3 Yes
104 20 2 1 pain drg5 No
104 20 4 1 pain drg1 No
104 43 1 1 vomit drg4 Yes
104 23 5 1 headache drg1 No
;;;;
run;quit;

/*     _                    ____
 _ __ | |__   __ _ ___  ___|___ \
| `_ \| `_ \ / _` / __|/ _ \ __) |
| |_) | | | | (_| \__ \  __// __/
| .__/|_| |_|\__,_|___/\___|_____|
|_|
*/

data sd1.phase2;
length key $8.;
input PID$ AGE$ Visit$ phase$ event$  drg$ study $;
key=cats(PID, AGE, Visit);
keep key event drg study;
cards4;
101 23 1 2 asthma parace Yes
102 32 1 2 asthma . Yes
101 23 2 2 acidity drg1 Yes
103 43 1 2 vomit drg4 Yes
103 43 2 2 pain drg5 No
103 43 4 2 pan drg5 No
107 43 3 2 pain drg5 No
104 20 1 1 fever drg6 Yes
104 20 3 1 headache drg1 No
104 20 2 1 pain drg5 No
;;;;
run;quit;

/**************************************************************************************************************************/
/*                 SD1.PHASE1                              SD1.PHASE 2                                                    */
/*                                                                                                                        */
/*  Obs     KEY      EVENT       DRG         STUDY    KEY      EVENT        DRG      STUDY                                */
/*                                                                                                                        */
/*  1    101231    asthma      parace       Yes      101231    asthma      parace     Yes                                 */
/*  2    102321    asthma      sinarest     Yes      102321    asthma                 Yes                                 */
/*  3    101232    acidity     drg1         No       101232    acidity     drg1       Yes                                 */
/*  4    103431    vomit       drg5         Yes      103431    vomit       drg4       Yes                                 */
/*  5    103432    fever       drg5         No       103432    pain        drg5       No                                  */
/*  6    103433    pain        drg4         Yes      103434    pan         drg5       No                                  */
/*  7    104206    fever       drg6         No       107433    pain        drg5       No                                  */
/*  8    104207    headache    5rg1         No       104201    fever       drg6       Yes                                 */
/*  9    104208    pain        drg3         yes      104203    headache    drg1       No                                  */
/* 10    104233    headache    drg3         Yes      104202    pain        drg5       No                                  */
/* 11    104202    pain        drg5         No                                                                            */
/* 12    104204    pain        drg1         No                                                                            */
/* 13    104431    vomit       drg4         Yes                                                                           */
/* 14    104235    headache    drg1         No                                                                            */
/**************************************************************************************************************************/

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/

/*---- CREAT A MASTER LIST TO OF KEYS TO JOIN AGAINST ----*/

proc sql;
 create
    table allkey as
 select
     key
 from
    phase1
 union
    corr
 select
     key
 from
    phase2
;quit;

/**************************************************************************************************************************/
/* DISTINCT PRIMARY KEYS PHASE1 AND PHASE 2                                                                               */
/*                                                                                                                        */
/*  KEY                                                                                                                   */
/*                                                                                                                        */
/* 101231                                                                                                                 */
/* 101232                                                                                                                 */
/* 102321                                                                                                                 */
/* 103431                                                                                                                 */
/* 103432                                                                                                                 */
/* 103433                                                                                                                 */
/* 103434                                                                                                                 */
/* 104201                                                                                                                 */
/* 104202                                                                                                                 */
/* 104203                                                                                                                 */
/* 104204                                                                                                                 */
/* 104206                                                                                                                 */
/* 104207                                                                                                                 */
/* 104208                                                                                                                 */
/* 104233                                                                                                                 */
/* 104235                                                                                                                 */
/* 104431                                                                                                                 */
/* 107433                                                                                                                 */
/**************************************************************************************************************************/

/*---- LEFT JOIN AGAINST MASTER KEYS SO WE GET ALL THE DATA SIDE BY SIDE ----*/

proc datasets lib=work nolist nodetails;
 delete want;
run;quit;

proc sql;
   create
      table want as
   select
      l.key
     ,c.event as event_phase1
     ,r.event as event_phase2
     ,c.study as study_phase1
     ,r.study as study_phase2
     ,c.drg   as drg_phase1
     ,r.drg   as drg_phase2
     ,case
        when (missing(c.event) and not missing(r.event)) then "P2 ONLY "
        when (not missing(c.event) and missing(r.event)) then "P1 ONLY "
        when (c.event eq r.event                       ) then "MATCHING"
        when (c.event ne r.event                       ) then "NO MATCH"
        else "ERROR"
      end as event
     ,case
        when (missing(c.study) and not missing(r.study)) then "P2 ONLY "
        when (not missing(c.study) and missing(r.study)) then "P1 ONLY "
        when (c.study eq r.study                       ) then "MATCHING"
        when (c.study ne r.study                       ) then "NO MATCH"
        else "ERROR"
     end as study
     ,case
        when (missing(c.drg) and not missing(r.drg)) then "P2 ONLY "
        when (not missing(c.drg) and missing(r.drg)) then "P1 ONLY "
        when (c.drg eq r.drg                       ) then "MATCHING"
        when (c.drg ne r.drg                       ) then "NO MATCH"
        else "ERROR"
     end as drg
   from
      allkey as l
   left join sd1.phase1 as c on l.key=c.key
   left join sd1.phase2 as r on l.key=r.key
;quit;


/**************************************************************************************************************************/
/*                  EVENT_      EVENT_      STUDY_    STUDY_    DRG_         DRG_                                         */
/* Obs     KEY      PHASE1      PHASE2      PHASE1    PHASE2    PHASE1      PHASE2     EVENT       STUDY        DRG       */
/*                                                                                                                        */
/*   1    101231    asthma      asthma       Yes       Yes      parace      parace    MATCHING    MATCHING    MATCHING    */
/*   2    101232    acidity     acidity      No        Yes      drg1        drg1      MATCHING    NO MATCH    MATCHING    */
/*   3    102321    asthma      asthma       Yes       Yes      sinarest              MATCHING    MATCHING    P1 ONLY     */
/*   4    103431    vomit       vomit        Yes       Yes      drg5        drg4      MATCHING    MATCHING    NO MATCH    */
/*   5    103432    fever       pain         No        No       drg5        drg5      NO MATCH    MATCHING    MATCHING    */
/*   6    103433    pain                     Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*   7    103434                pan                    No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY     */
/*   8    104201                fever                  Yes                  drg6      P2 ONLY     P2 ONLY     P2 ONLY     */
/*   9    104202    pain        pain         No        No       drg5        drg5      MATCHING    MATCHING    MATCHING    */
/*  10    104203                headache               No                   drg1      P2 ONLY     P2 ONLY     P2 ONLY     */
/*  11    104204    pain                     No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  12    104206    fever                    No                 drg6                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  13    104207    headache                 No                 5rg1                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  14    104208    pain                     yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  15    104233    headache                 Yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  16    104235    headache                 No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  17    104431    vomit                    Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY     */
/*  18    107433                pain                   No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY     */
/**************************************************************************************************************************/

/*___                              _
|___ \   ___  __ _ ___   ___  __ _| |   __ _ _ __ _ __ __ _ _   _ ___
  __) | / __|/ _` / __| / __|/ _` | |  / _` | `__| `__/ _` | | | / __|
 / __/  \__ \ (_| \__ \ \__ \ (_| | | | (_| | |  | | | (_| | |_| \__ \
|_____| |___/\__,_|___/ |___/\__, |_|  \__,_|_|  |_|  \__,_|\__, |___/
                                |_|                         |___/
*/

%array(_vr,values=EVENT DRG STUDY);

ARRAY ELEMENTS

%put &_vr1;  * GLOBAL _VR1 EVENT  ;
%put &_vr2;  * GLOBAL _VR2 DRG    ;
%put &_vr3;  * GLOBAL _VR3 STUDY  ;
%put &_vrn;  * GLOBAL _VRN 3      ;


proc datasets lib=work nolist nodetails;
 delete want;
run;quit;

proc sql;
   create
      table want as
   select
      l.key
  ,%do_over(_vr,phrase=%str(
      c.? as ?_phase1
     ,r.? as ?_phase2
     ,case
        when (missing(c.?) and not missing(r.?)) then "P2 ONLY "
        when (not missing(c.?) and missing(r.?)) then "P1 ONLY "
        when (c.? eq r.?                       ) then "MATCHING"
        when (c.? ne r.?                       ) then "NO MATCH"
        else "ERROR"
     end as ?),between=comma)
   from
      allkey as l
   left join sd1.phase1 as c on l.key=c.key
   left join sd1.phase2 as r on l.key=r.key
;quit;

/*---- CLEAN UP MACRO ARRAY ----*/

%arraydelete(_vr);

/*____                    _
|___ /   _ __   ___  __ _| |
  |_ \  | `__| / __|/ _` | |
 ___) | | |    \__ \ (_| | |
|____/  |_|    |___/\__, |_|
                       |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete rwant;
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
phase1<-read_sas("d:/sd1/phase1.sas7bdat")
phase2<-read_sas("d:/sd1/phase2.sas7bdat")
want <- sqldf('
 with
   allkey  as (
     select
         key
     from
        phase1
     union
     select
         key
     from
        phase2)
   select
      l.key
     ,c.event as event_phase1
     ,r.event as event_phase2
     ,c.study as study_phase1
     ,r.study as study_phase2
     ,c.drg   as drg_phase1
     ,r.drg   as drg_phase2
     ,case
        when (c.event is null and r.event is not null) then "P2 ONLY "
        when (c.event is not null and r.event is null) then "P1 ONLY "
        when (c.event =  r.event                     ) then "MATCHING"
        when (c.event <> r.event                     ) then "NO MATCH"
        else "ERROR"
      end as event
     ,case
        when (c.study is null and r.study is not null) then "P2 ONLY "
        when (c.study is not null and r.study is null) then "P1 ONLY "
        when (c.study =  r.study                     ) then "MATCHING"
        when (c.study <> r.study                     ) then "NO MATCH"
        else "ERROR"
     end as study
     ,case
        when (c.drg is null and r.drg is not null) then "P2 ONLY "
        when (c.drg is not null and r.drg is null) then "P1 ONLY "
        when (c.drg =  r.drg                     ) then "MATCHING"
        when (c.drg <> r.drg                     ) then "NO MATCH"
        else "ERROR"
     end as drg
   from
      allkey as l
      left join phase1 as c on l.key=c.key
      left join phase2 as r on l.key=r.key
   ')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rwant;
run;quit;

/***************************************************************************************************************************/
/* R                                                                                                                       */
/* want                                                                                                                    */
/*                                                                                                                         */
/*     key event_phase1 event_phase2 study_phase1 study_phase2 drg_phase1  drg_phase2    event    study      drg           */
/*                                                                                                                         */
/*  101231       asthma       asthma          Yes          Yes     parace      parace MATCHING MATCHING MATCHING           */
/*  101232      acidity      acidity           No          Yes       drg1        drg1 MATCHING NO MATCH MATCHING           */
/*  102321       asthma       asthma          Yes          Yes   sinarest             MATCHING MATCHING NO MATCH           */
/*  103431        vomit        vomit          Yes          Yes       drg5        drg4 MATCHING MATCHING NO MATCH           */
/*  103432        fever         pain           No           No       drg5        drg5 NO MATCH MATCHING MATCHING           */
/*  103433         pain         <NA>          Yes         <NA>       drg4        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  103434         <NA>          pan         <NA>           No       <NA>        drg5 P2 ONLY  P2 ONLY  P2 ONLY            */
/*  104201         <NA>        fever         <NA>          Yes       <NA>        drg6 P2 ONLY  P2 ONLY  P2 ONLY            */
/*  104202         pain         pain           No           No       drg5        drg5 MATCHING MATCHING MATCHING           */
/*  104203         <NA>     headache         <NA>           No       <NA>        drg1 P2 ONLY  P2 ONLY  P2 ONLY            */
/*  104204         pain         <NA>           No         <NA>       drg1        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104206        fever         <NA>           No         <NA>       drg6        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104207     headache         <NA>           No         <NA>       5rg1        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104208         pain         <NA>          yes         <NA>       drg3        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104233     headache         <NA>          Yes         <NA>       drg3        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104235     headache         <NA>           No         <NA>       drg1        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  104431        vomit         <NA>          Yes         <NA>       drg4        <NA> P1 ONLY  P1 ONLY  P1 ONLY            */
/*  107433         <NA>         pain         <NA>           No       <NA>        drg5 P2 ONLY  P2 ONLY  P2 ONLY            */
/*                                                                                                                         */
/* SAS                                                                                                                     */
/*                     EVENT_      EVENT_      STUDY_    STUDY_    DRG_         DRG_                                       */
/*  ROWNAMES  KEY      PHASE1      PHASE2      PHASE1    PHASE2    PHASE1      PHASE2     EVENT       STUDY        DRG     */
/*                                                                                                                         */
/*      1    101231    asthma      asthma       Yes       Yes      parace      parace    MATCHING    MATCHING    MATCHING  */
/*      2    101232    acidity     acidity      No        Yes      drg1        drg1      MATCHING    NO MATCH    MATCHING  */
/*      3    102321    asthma      asthma       Yes       Yes      sinarest              MATCHING    MATCHING    NO MATCH  */
/*      4    103431    vomit       vomit        Yes       Yes      drg5        drg4      MATCHING    MATCHING    NO MATCH  */
/*      5    103432    fever       pain         No        No       drg5        drg5      NO MATCH    MATCHING    MATCHING  */
/*      6    103433    pain                     Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*      7    103434                pan                    No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY   */
/*      8    104201                fever                  Yes                  drg6      P2 ONLY     P2 ONLY     P2 ONLY   */
/*      9    104202    pain        pain         No        No       drg5        drg5      MATCHING    MATCHING    MATCHING  */
/*     10    104203                headache               No                   drg1      P2 ONLY     P2 ONLY     P2 ONLY   */
/*     11    104204    pain                     No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     12    104206    fever                    No                 drg6                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     13    104207    headache                 No                 5rg1                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     14    104208    pain                     yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     15    104233    headache                 Yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     16    104235    headache                 No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     17    104431    vomit                    Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY   */
/*     18    107433                pain                   No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY   */
/***************************************************************************************************************************/

/*  _                 _   _                             _
| || |    _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
| || |_  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
|__   _| | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
   |_|   | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
         |_|    |___/                                |_|
*/

proc datasets lib=sd1 nolist nodetails;
 delete pywant;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
phase1,meta = ps.read_sas7bdat('d:/sd1/phase1.sas7bdat');
phase2,meta = ps.read_sas7bdat('d:/sd1/phase2.sas7bdat');
want=pdsql('''
 with
   allkey  as (
     select
         key
     from
        phase1
     union
     select
         key
     from
        phase2)
   select
      l.key
     ,c.event as event_phase1
     ,r.event as event_phase2
     ,c.study as study_phase1
     ,r.study as study_phase2
     ,c.drg   as drg_phase1
     ,r.drg   as drg_phase2
     ,case
        when (c.event is null and r.event is not null) then "P2 ONLY "
        when (c.event is not null and r.event is null) then "P1 ONLY "
        when (c.event =  r.event                     ) then "MATCHING"
        when (c.event <> r.event                     ) then "NO MATCH"
        else "ERROR"
      end as event
     ,case
        when (c.study is null and r.study is not null) then "P2 ONLY "
        when (c.study is not null and r.study is null) then "P1 ONLY "
        when (c.study =  r.study                     ) then "MATCHING"
        when (c.study <> r.study                     ) then "NO MATCH"
        else "ERROR"
     end as study
     ,case
        when (c.drg is null and r.drg is not null) then "P2 ONLY "
        when (c.drg is not null and r.drg is null) then "P1 ONLY "
        when (c.drg =  r.drg                     ) then "MATCHING"
        when (c.drg <> r.drg                     ) then "NO MATCH"
        else "ERROR"
     end as drg
   from
      allkey as l
      left join phase1 as c on l.key=c.key
      left join phase2 as r on l.key=r.key
   ''');
print(want);
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/* PYTHON                                                                                                                 */
/*        key event_phase1 event_phase2  ...     event     study       drg                                                */
/*                                                                                                                        */
/* 0   101231       asthma       asthma  ...  MATCHING  MATCHING  MATCHING                                                */
/* 1   101232      acidity      acidity  ...  MATCHING  NO MATCH  MATCHING                                                */
/* 2   102321       asthma       asthma  ...  MATCHING  MATCHING  NO MATCH                                                */
/* 3   103431        vomit        vomit  ...  MATCHING  MATCHING  NO MATCH                                                */
/* 4   103432        fever         pain  ...  NO MATCH  MATCHING  MATCHING                                                */
/* 5   103433         pain         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 6   103434         None          pan  ...  P2 ONLY   P2 ONLY   P2 ONLY                                                 */
/* 7   104201         None        fever  ...  P2 ONLY   P2 ONLY   P2 ONLY                                                 */
/* 8   104202         pain         pain  ...  MATCHING  MATCHING  MATCHING                                                */
/* 9   104203         None     headache  ...  P2 ONLY   P2 ONLY   P2 ONLY                                                 */
/* 10  104204         pain         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 11  104206        fever         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 12  104207     headache         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 13  104208         pain         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 14  104233     headache         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 15  104235     headache         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 16  104431        vomit         None  ...  P1 ONLY   P1 ONLY   P1 ONLY                                                 */
/* 17  107433         None         pain  ...  P2 ONLY   P2 ONLY   P2 ONLY                                                 */
/*                                                                                                                        */
/* SAS                                                                                                                    */
/*           EVENT_      EVENT_      STUDY_    STUDY_    DRG_         DRG_                                                */
/*  KEY      PHASE1      PHASE2      PHASE1    PHASE2    PHASE1      PHASE2     EVENT       STUDY        DRG              */
/*                                                                                                                        */
/* 101231    asthma      asthma       Yes       Yes      parace      parace    MATCHING    MATCHING    MATCHING           */
/* 101232    acidity     acidity      No        Yes      drg1        drg1      MATCHING    NO MATCH    MATCHING           */
/* 102321    asthma      asthma       Yes       Yes      sinarest              MATCHING    MATCHING    NO MATCH           */
/* 103431    vomit       vomit        Yes       Yes      drg5        drg4      MATCHING    MATCHING    NO MATCH           */
/* 103432    fever       pain         No        No       drg5        drg5      NO MATCH    MATCHING    MATCHING           */
/* 103433    pain                     Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 103434                pan                    No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY            */
/* 104201                fever                  Yes                  drg6      P2 ONLY     P2 ONLY     P2 ONLY            */
/* 104202    pain        pain         No        No       drg5        drg5      MATCHING    MATCHING    MATCHING           */
/* 104203                headache               No                   drg1      P2 ONLY     P2 ONLY     P2 ONLY            */
/* 104204    pain                     No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104206    fever                    No                 drg6                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104207    headache                 No                 5rg1                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104208    pain                     yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104233    headache                 Yes                drg3                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104235    headache                 No                 drg1                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 104431    vomit                    Yes                drg4                  P1 ONLY     P1 ONLY     P1 ONLY            */
/* 107433                pain                   No                   drg5      P2 ONLY     P2 ONLY     P2 ONLY            */
/**************************************************************************************************************************/

%utlfkil(d:/xls/wantxl.xlsx);

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
library(haven)
phase1<-read_sas("d:/sd1/phase1.sas7bdat")
phase2<-read_sas("d:/sd1/phase2.sas7bdat")
wb <- createWorkbook()
addWorksheet(wb, "phase1")
writeData(wb, sheet = "phase1", x = phase1)
addWorksheet(wb, "phase2")
writeData(wb, sheet = "phase2", x = phase2)
saveWorkbook(
    wb
   ,"d:/xls/wantxl.xlsx"
   ,overwrite=TRUE)
;;;;
%utl_rendx;

%utl_rbeginx;
parmcards4;
library(openxlsx)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
 wb<-loadWorkbook("d:/xls/wantxl.xlsx")
 phase1<-read.xlsx(wb,"phase1")
 phase2<-read.xlsx(wb,"phase2")
 addWorksheet(wb, "want")
 want <- sqldf('
 with
   allkey  as (
     select
         key
     from
        phase1
     union
     select
         key
     from
        phase2)
   select
      l.key
     ,c.event as event_phase1
     ,r.event as event_phase2
     ,c.study as study_phase1
     ,r.study as study_phase2
     ,c.drg   as drg_phase1
     ,r.drg   as drg_phase2
     ,case
        when (c.event is null and r.event is not null) then "P2 ONLY "
        when (c.event is not null and r.event is null) then "P1 ONLY "
        when (c.event =  r.event                     ) then "MATCHING"
        when (c.event <> r.event                     ) then "NO MATCH"
        else "ERROR"
      end as event
     ,case
        when (c.study is null and r.study is not null) then "P2 ONLY "
        when (c.study is not null and r.study is null) then "P1 ONLY "
        when (c.study =  r.study                     ) then "MATCHING"
        when (c.study <> r.study                     ) then "NO MATCH"
        else "ERROR"
     end as study
     ,case
        when (c.drg is null and r.drg is not null) then "P2 ONLY "
        when (c.drg is not null and r.drg is null) then "P1 ONLY "
        when (c.drg =  r.drg                     ) then "MATCHING"
        when (c.drg <> r.drg                     ) then "NO MATCH"
        else "ERROR"
     end as drg
   from
      allkey as l
      left join phase1 as c on l.key=c.key
      left join phase2 as r on l.key=r.key
   ')
 print(want)
 writeData(wb,sheet="want",x=want)
 saveWorkbook(
     wb
    ,"d:/xls/wantxl.xlsx"
    ,overwrite=TRUE)
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/* -----------------------+                                                                                               */
/* | A1| fx    |  KEY     |                                                                                               */
/* -------------------------------------------------------------------------------------------------+                     */
/* [_] |    A  |    B   |    C    |    E    |     F   |    G  |  H   |    I   |    J     |   K      |                     */
/* -------------------------------------------------------------------------------------------------|                     */
/*  1 | KEY    | EVTOLD |  EVTNEW |   STYOLD|  STYNEW | DRGOLD|DRGNEW| EVENT  |   STUDY  |     DRG  |                     */
/*  --|-------+-----------------------------------------------+---------+-------------------+-------|                     */
/*  2  101231 | asthma  | asthma  | Yes     | Yes     |parace |parace| MATCHING| NO MATCH | MATCHING|                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  3  101232 | acidity | acidity | No      | No      | drg1  | drg1 | MATCHING| MATCHING | NO MATCH|                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  4  102321 | asthma  | asthma  | Yes     | Yes     | sinart| sinar| MATCHING| MATCHING | NO MATCH|                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  5  103431 | vomit   | vomit   | Yes     | Yes     | drg5  | drg5 | NO MATCH| MATCHING | MATCHING|                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  6  103432 | fever   | fever   | No      | No      | drg5  | drg5 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  7  103433 | pain    | pain    | Yes     | Yes     | drg4  | drg4 | P2 ONLY | P2 ONLY  | P2 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  8  104202 | pain    | pain    | No      | No      | drg5  | drg5 | P2 ONLY | P2 ONLY  | P2 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/*  9  104204 | pain    | pain    | No      | No      | drg1  | drg1 | MATCHING| MATCHING | MATCHING|                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/* 10  104206 | fever   | fever   | No      | No      | drg6  | drg6 | P2 ONLY | P2 ONLY  | P2 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/* 11  104207 | headache| headache| No      | No      | 5rg1  | 5rg1 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/* 12  104208 | pain    | pain    | yes     | yes     | drg3  | drg3 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/* 13  104233 | headache| headache| Yes     | Yes     | drg3  | drg3 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*   - ---------------------------------------------------------------------------------------------|                     */
/* 14  104235 | headache| headache| No      | No      | drg1  | drg1 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*   - -------------------------------------------------------------------------------------------- |                     */
/* 15  104431 | vomit   | vomit   | Yes     | Yes     | drg4  | drg4 | P1 ONLY | P1 ONLY  | P1 ONLY |                     */
/*  |-|--------------+---------+---------+---------+----------------------------+-----------+-------|                     */
/*  |-|....................                                                                                               */
/*  [WANT]                                                                                                                */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
