Listing instruments:

`POST /micis/remote/getStudyData.php, {
    :type => "instruments",
    :id => STUDY_ID
}`

Returns Javascript array of {instrument_id, label}

Listing visits:

`POST /micis/remote/getStudyData.php, {
    :type => "visits",
    :id => STUDY_ID
}`

Listing URISs:

`POST /micis/remote/getStudyData.php, {
    :type => "getsubjects",
    :q => {"ursisInStudy":"6860"}
}`

`POST /micis/remote/getStudyData.php, {
    :type => "questions",
    :id => INSTRUMENT_ID
}`

Preview:

`POST /micis/remote/getStudyData.php, {
    :type => "getresults",
    :q => {"collapseseries":true,"demoPieces":[],"erpscans":false,"fieldSeparator":"u0009","includequestdesc":"yes","includeAsmtMeta":"yes","lineSeparator":"u000a","missingDataVal":"-1001","dontKnowVal":"-1002","maxrecordsreturn":500,"optCollapseByURSI":false,"optMostCompleteEntries":false,"orientation":"crossCollapse","scanOrientation":"normalOneCell","outputPieces":[{"instrumentId":"27563","instrumentLabel":"ET","visitId":"0","visitLabel":"All Visits","fieldId":"0","fieldLabel":"All Fields","studyId":"6860"}],"outputScanPieces":[],"qPieces":[],"returnall":false,"scanPieces":[],"textqualifier":"\"","ursiList":"","ursisInStudy":"6860","validSpecifiedUrsis":"M53723902,M53733892,M53726766,M53738714,M53725449,M53769951,M53791792,M53735450,M53756729,M53773069,M53710255,M53741200,M53794583,M53713086,M53722212,M53778213,M53728295,M53772832,M53712467,M53708901,M53774060,M53744261,M53734888,M53777034,M53773421,M53778044,M53748565,M53707913,M53702213,M53744162,M53738784,M53758912,M53766359,M53746525,M53703459,M53737809,M53703640,M53731516,M53716922,M53749708,M53759518,M53755332,M53700686,M53774418,M53707153,M53702644,M53789104,M53713238,M53715719,M53778250,M53717184,M53792555,M53751828,M53722512,M53738542,M53729191,M53715506,M53737521,M53755253,M53714570,M53733824,M53760804,M53732200,M53786285,M53787528,M53718668,M53746692,M53734966,M53727943,M53723906,M53732378,M53700046,M53796505","visitorientation":"updown","questFormatSegInt":true,"questFormatSegInst":true,"questFormatEC":false,"questFormatSiteCt":false,"questFormatSourceCt":false,"questFormatRaterCt":false,"questFormatQuesInst":true,"questFormatDrop1":true,"allQueriedFields":false,"limitStSrcRt":true,"printFirstOnlyAsmt":false,"showMissingAsPd":false,"asmtBoolLogic":false,"scanBoolLogic":false,"showOnlyDataUrsis":false}
}`

Actual data:

`POST /micis/downloadcsv.php?action=1, {
    :ds => "scansorassessments",
    :q => {"collapseseries":true,"demoPieces":[],"erpscans":false,"fieldSeparator":"u0009","includequestdesc":"yes","includeAsmtMeta":"yes","lineSeparator":"u000a","missingDataVal":"-1001","dontKnowVal":"-1002","maxrecordsreturn":500,"optCollapseByURSI":false,"optMostCompleteEntries":false,"orientation":"crossCollapse","scanOrientation":"normalOneCell","outputPieces":[{"instrumentId":"INSTRUMENTID","instrumentLabel":"INSLABEL","visitId":"0","visitLabel":"All Visits","fieldId":"0","fieldLabel":"All Fields","studyId":"STUDYID"}],"outputScanPieces":[],"qPieces":[],"returnall":false,"scanPieces":[],"textqualifier":"\"","ursiList":"","ursisInStudy":"STUDY_ID","visitorientation":"updown","questFormatSegInt":true,"questFormatSegInst":true,"questFormatEC":false,"questFormatSiteCt":false,"questFormatSourceCt":false,"questFormatRaterCt":false,"questFormatQuesInst":true,"questFormatDrop1":true,"allQueriedFields":false,"limitStSrcRt":true,"printFirstOnlyAsmt":false,"showMissingAsPd":false,"asmtBoolLogic":false,"scanBoolLogic":false,"showOnlyDataUrsis":false}
}`