piggybank
=========

A ruby library to integrate with MRN's COINS database.

This library is horribly brittle and you should probably not use it unless you like gluing together broken pieces of things when they break.


### Documentation

Install [RDoc](https://github.com/rdoc/rdoc) and run `rdoc` in the base directory of your piggybank checkout.

Look at the glorious examples in [the examples directory](tree/master/examples).


### Things you can do

1. List studies

  * require 'piggybank'
  * pb = Piggybank.logged_in_from_file
  * studies = pb.list_studies

2. List subjects in a study

  * subjects = pb.list_subjects(studyID)

3. List subjects via metaportal

  * subjects = pb.list_subjects_from_metaportal(metaportalURL)

4. Get demographics by URSI

  * demographics = pb.get_demographics_by_ursi(URSI)

5. Get tags by URSI

  * tags = pb.get_tags_by_ursi(URSI)

6. Get subject study-enrollment info by URSI

  * enrollment = pb.get_enrollment_by_ursi(URSI)

7. Get subject diversity details by URSI

  * details = pb.get_details_by_ursi(URSI)

8. List instruments in a study

  * instruments = pb.list_instruments(studyID)

9. Find an instrument ID by name

  * instrumentID = pb.find_instrument_id_by_name(studyID, instrumentName)

10. Get all assessments for a given study + instrument (+ optional URSI)

  * assessments = pb.get_assessments(studyID, instrumentID, URSI)

11. Get all assessment DETAILS for a given study + instrument (+ optional URSI)

  * assessmentDetails = pb.get_assessment_details(studyID, instrumentID, URSI)

12. Get all DETAILS for a given study + assessment

  * assessmentDetails = pb.get_assessment_details_by_id(studyID, assessmentID) 
  

### Random notes

Assessment data URLs are of the format:

https://chronus.mrn.org/micis/asmt/manage/downloadcsv.php?filename=assessmentsResults&assessmentsIDs=ID1,ID2&displayType=responseValue
