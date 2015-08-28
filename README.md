piggybank
=========

A ruby library to integrate with MRN's COINS database.

This library is horribly brittle and you should probably not use it unless you like gluing together broken pieces of things when they break.


### Documentation

Install [RDoc](https://github.com/rdoc/rdoc) and run `rdoc` in the base directory of your piggybank checkout.

Look at the glorious examples in [the examples directory](tree/master/examples).


### Things you can do

1. List studies
2. List subjects in a study
3. List subjects via metaportal
4. Get demographics by URSI
5. List instruments in a study
6. Get all assessments for a given study + instrument
7. Get all assessment DETAILS for a given study + instrument
8. Get all assessment DETAILS for a given study + instrument + URSI
  

### Random notes

Assessment data URLs are of the format:

https://chronus.mrn.org/micis/asmt/manage/downloadcsv.php?filename=assessmentsResults&assessmentsIDs=ID1,ID2&displayType=responseValue
