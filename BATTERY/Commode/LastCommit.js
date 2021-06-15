// Load modules
loadModule('/System/Resources');
loadModule('/Bachmann/Solution');
loadModule('/Bachmann/Device');
loadModule('/System/Git');
loadModule("/System/Build");
loadModule("/System/UI");

//Where to save file. Should be one level up from Commode, i.e at git repo root
var filepath = "../fb_LastCommit.st"
	
//Add new git repositories to the array below when needed
var repos = ["DRIVE", "GENERATOR", "CHARGER", "BATTERY", "UGRID", "ShoreCTRL", "DCGUARD", "STATIC", "BOOSTER", "QUEST"];

//Selection Box
var projectName = showSelectionDialog(repos, "Choose Repo", "Choose Git Repository");

// Make a project handle for JS
var project = getProject(projectName);

//If solution is not found print a message to console
if(!project.exists()){
    print('Project not found');
}

else {
    //Get the Git repo information
    var repo = openRepository(project);
    print('Step 1; Repository Opened');
   
    //Make Reference to currently checked out commit
    var commit = repo.getRepository().findRef('HEAD').getObjectId().getName();
    print('Step 2; Commit Reference Found');
    
    //Open the file and write over the content
    var fileHandle = openFile(filepath);
    print('Step 3; File Opened;' + fileHandle );
    
    //Read Contents of file
    var file = readFile(fileHandle);
    print('Step 4: File read');
    
    //Create content of fb_LastCommit.st
    var Fb = "FUNCTION_BLOCK fb_LastCommit\n" +
    		"VAR_OUTPUT\n" +
    			"\tLastCommitShort: \t\t\tSTRING; (*Short hand commit hash*) \n" +
    			"\tLastCommitFull: \t\t\tSTRING; (*Full commit hash*)\n" +
    		"END_VAR\n" +
    		"VAR  \n" +
    			"\thash:\t\t\t\t\t\tSTRING;\n" +
			"END_VAR \n" +
				"\thash := \t\t\t\t\t'" + commit + "';\n" +
				"\tLastCommitShort := \t\t\tLEFT(hash,7);\n" +
				"\tLastCommitFull := \t\t\thash;\n" +
			"END_FUNCTION_BLOCK";
    
    var writeFileResult = writeFile(filepath, Fb, WRITE, true);
    print('File: ' + filepath + ' created. Handle:' + writeFileResult);
   
    //Build the project
    build(projectName, FULL_BUILD);
    print('Project Built, file saved and have a nice day')
}
