// Quick and dirty code
#pragma dynamic 320000
#define isnull(%1) \
			((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#define isNull isnull
#define IsNull isNull
			
#include <a_samp>
#include <sscanf2>
new SQL_Connection;
#define SQL_Host	"localhost"
#define SQL_User	"freeroam"
#define SQL_Pass	""
#define SQL_DB		"freeroam"
#include 	<a_mysql>
forward InsertObject(objectid, name[], comment[]);
public OnGameModeExit()
{
	mysql_close(SQL_Connection);
	return 1;
}
main() print("\n------------------\n");
public OnGameModeInit()
{
	mysql_debug(1);
	SQL_Connection = mysql_connect(SQL_Host, SQL_User, SQL_DB, SQL_Pass);

	AddPlayerClass(0,0,0,0,0,0,0,0,0,0,0);
	printf("Starting UP!");
	SetGameModeText("Ventura's DM~MG");
	
	new zbuffer[256];
	new FilePaths[]="obj/objects.txt";
	new Files[200][128];
	new lineCount=0;
	new File:FileList = fopen(FilePaths, io_read);
	printf("Reading from: %s", FilePaths);
	if(!fexist(FilePaths)) printf("Erorr 404!");
	while(fread(FileList, zbuffer))
	{
		strcat(Files[lineCount], zbuffer, 128);
		StripNL(zbuffer);
		printf(zbuffer);
		lineCount++;
	}
	fclose(FileList);
	printf("Done Reading from: %s", FilePaths);
	
   	new UpdateTrigger[]="obj\\obj_injected.txt";
   	new TriggerUpdate[]="obj\\obj_update.txt";
	if(!fexist(UpdateTrigger))
	{
		new lineS=0;
		while(lineS < lineCount) // Try to open files and read content
		{
			new len = strlen(Files[lineS]);
			for(new i=0; i < len; i++)
			{
				if(Files[lineS][i] <= ' ') Files[lineS][i] = EOS;
			}
			if(!fexist(Files[lineS]))
			{
				printf("404: [%i] '%s'",lineS,Files[lineS]);
				lineS++;
				continue;
			}
			new buffer[256];
			new File:TMP=fopen(Files[lineS], io_read);
			while(fread(TMP, buffer))
			{
				printf("Fread: '%s'", Files[lineS]);
				printf("lineS %i < lineCount %i", lineS, lineCount);
				print(buffer);
				printf("MEM: %s #%i %s", Files[lineS], lineS, buffer);
				if(strfind(Files[lineS], ".models", true) == -1)
				{
					printf("<< Fread: '%s'", Files[lineS]);
					new Category[64];
					if(strfind(Files[lineS], "SA-MP.ide", true) != -1){
						format(Category, sizeof(Category), "SA-MP");
					}else{
						format(Category, sizeof(Category), "Unknown");
					}
					strreplace(buffer, ", ", ",", true);
					strreplace(buffer, " ,", ",", true);
					strreplace(buffer, " ", ",", true);
					new obj_comment[64];
					new obj_name[64];
					new obj_model;
					sscanf(buffer, "p<,>is[63]s[63]{S[63]}",obj_model,obj_name,obj_comment);
					printf("IDE: %i '%s' '%s'", obj_model, obj_name, obj_comment);
					
					printf("buffer: %s", buffer);

					printf("MEM: %s #%i %s", Files[lineS], lineS, buffer);
					printf("Category: %s\n################", Category);
					
					new Query[320];
					format(Query, 256, "INSERT INTO `objects` (Model, Name, Comment, Category) VALUES (%i, '%s', '%s', '%s')",obj_model,obj_name,obj_comment, Category);
					mysql_function_query(SQL_Connection,Query,false,"InsertObject", "i", obj_model);
				}
			}
			fclose(TMP);
			lineS++;
		}
		printf("Done!");
		
		new File:SetUpdate=fopen(UpdateTrigger, io_write);
		if(SetUpdate)
		{
			fwrite(SetUpdate, "True");
			fclose(SetUpdate);
		}
	}else{
		new lineZ=0;
		while(lineZ < lineCount) // Try to open files and read content
		{
			new len = strlen(Files[lineZ]);
			for(new i=0; i < len; i++)
			{
				if(Files[lineZ][i] <= ' ') Files[lineZ][i] = EOS;
			}
			if(!fexist(Files[lineZ]))
			{
				printf("404: [%i] '%s'",lineZ,Files[lineZ]);
				lineZ++;
				continue;
			}
			new buffer[256];
			new File:TEMP=fopen(Files[lineZ], io_read);
			while(fread(TEMP, buffer))
			{
				printf("Fread: '%s'", Files[lineZ]);
				printf("lineZ %i < lineCount %i", lineZ, lineCount);
				print(buffer);
				printf("MEM: %s #%i %s", Files[lineZ], lineZ, buffer);
				if(strfind(Files[lineZ], ".ide", true) != -1)
				{
					printf("IDE FILE");
					strreplace(buffer, ", ", ",", true);
					strreplace(buffer, " ,", ",", true);
					strreplace(buffer, " ", ",", true);
					printf(">> IDE FILE");
					new obj_model;
					sscanf(buffer, "p<,>i{s[63]s[63]S[63]}",obj_model);
					printf("<< IDE FILE");
					if(strfind(Files[lineZ], "sa-mp.ide", true) == -1)
					{
						printf("SSCANF IDE FILE");
						new fname[64];
						sscanf(Files[lineZ], "p<\\>{s[63]s[63]p<.>}s[63]{s[63]}",fname);
						printf("OK IDE FILE");
						new query[320];
						format(query,sizeof(query),"UPDATE `objects` SET `IDE` = '%s' WHERE `Model` = '%i'", fname, obj_model);
						mysql_function_query(SQL_Connection,query,false,"InsertObject","i",obj_model);
						printf("IDE: %i '%s'", obj_model, fname);
		   			}else{
		   				new query[320];
						format(query,sizeof(query),"UPDATE `objects` SET `IDE` = 'SA-MP' WHERE `Model` = '%i'", obj_model);
						mysql_function_query(SQL_Connection,query,false,"InsertObject","i",obj_model);
						printf("IDE: %i '%s'", obj_model, "sa-mp");
					}
					printf(">< IDE FILE");
				}else{
					printf("MTA FILE");
					new obj_model;
					sscanf(buffer, "p< >i{S[128]}",obj_model);
	 				if(!fexist(TriggerUpdate))
	 				{
		 				new Category[64];
						new Group[64];
						printf("MEM: %s #%i %s", Files[lineZ], lineZ, buffer);

						printf("MTA: %i", obj_model);

						if(strfind(Files[lineZ], "beach_and_sea", true) != -1){
							format(Category, sizeof(Category), "Beach And Sea");
						}else if(strfind(Files[lineZ], "buildings", true) != -1){
							format(Category, sizeof(Category), "Buildings");
						}else if(strfind(Files[lineZ], "industrial", true) != -1){
							format(Category, sizeof(Category), "Industrial");
						}else if(strfind(Files[lineZ], "interior_objects", true) != -1){
							format(Category, sizeof(Category), "Interior Objects");
						}else if(strfind(Files[lineZ], "KWK_All_Models_[buggyList]", true) != -1){
							format(Category, sizeof(Category), "KWK");
						}else if(strfind(Files[lineZ], "land_masses", true) != -1){
							format(Category, sizeof(Category), "Land Masses");
						}else if(strfind(Files[lineZ], "miscellaneous", true) != -1){
							format(Category, sizeof(Category), "Miscellaneous");
						}else if(strfind(Files[lineZ], "Missing_objects", true) != -1){
							format(Category, sizeof(Category), "Missing Objects");
						}else if(strfind(Files[lineZ], "nature", true) != -1){
							format(Category, sizeof(Category), "Nature");
						}else if(strfind(Files[lineZ], "structures", true) != -1){
							format(Category, sizeof(Category), "Structures");
						}else if(strfind(Files[lineZ], "transportation", true) != -1){
							format(Category, sizeof(Category), "Transportation");
						}else format(Category, sizeof(Category), "Unknown");

						new fname[64];
						sscanf(Files[lineZ], "p<\\>{s[63]s[63]s[63]}p<.>s[63]{S[63]}",fname);

						strcat(Group, fname);
						new Query[320];
						format(Query, 320, "INSERT INTO `objects` (Model, Category, MTA) VALUES (%i, '%s', '%s')",obj_model,Category,Group);
						mysql_function_query(SQL_Connection,Query,false,"InsertObject", "i", obj_model);
					}else{
		 				new Category[64];
						new Group[64];
						printf("MEM: %s #%i %s", Files[lineZ], lineZ, buffer);

						printf("<< MTA: %i", obj_model);

						if(strfind(Files[lineZ], "beach_and_sea", true) != -1){
							format(Category, sizeof(Category), "Beach And Sea");
						}else if(strfind(Files[lineZ], "buildings", true) != -1){
							format(Category, sizeof(Category), "Buildings");
						}else if(strfind(Files[lineZ], "industrial", true) != -1){
							format(Category, sizeof(Category), "Industrial");
						}else if(strfind(Files[lineZ], "interior_objects", true) != -1){
							format(Category, sizeof(Category), "Interior Objects");
						}else if(strfind(Files[lineZ], "KWK_All_Models_[buggyList]", true) != -1){
							format(Category, sizeof(Category), "KWK");
						}else if(strfind(Files[lineZ], "land_masses", true) != -1){
							format(Category, sizeof(Category), "Land Masses");
						}else if(strfind(Files[lineZ], "miscellaneous", true) != -1){
							format(Category, sizeof(Category), "Miscellaneous");
						}else if(strfind(Files[lineZ], "Missing_objects", true) != -1){
							format(Category, sizeof(Category), "Missing Objects");
						}else if(strfind(Files[lineZ], "nature", true) != -1){
							format(Category, sizeof(Category), "Nature");
						}else if(strfind(Files[lineZ], "structures", true) != -1){
							format(Category, sizeof(Category), "Structures");
						}else if(strfind(Files[lineZ], "transportation", true) != -1){
							format(Category, sizeof(Category), "Transportation");
						}else format(Category, sizeof(Category), "Unknown");

						new fname[64];
						sscanf(Files[lineZ], "p<\\>{s[63]s[63]s[63]}p<.>s[63]{S[63]}",fname);

						strcat(Group, fname);
						new Query[320];
						
						
						strreplace(Group, ",", "_", true);
						strreplace(Group, "__", "_", true);
						strreplace(Group, "_", " ", true);
						
						format(Query, 320, "UPDATE `objects` SET `Category` = '%s', `MTA` = '%s' WHERE `Model` = %i)",Category,Group,obj_model);
						printf("Query: <%s>", Query);
						//mysql_function_query(SQL_Connection,Query,false,"InsertObject", "i", obj_model);
					}
				}
				printf("<|> FILE");
			}
			fclose(TEMP);

			printf("lineZ: %i", lineZ);
			
			lineZ++;
		}
		printf("Done?");
	}
	new File:SetUpdate=fopen(TriggerUpdate, io_write);
	if(SetUpdate)
	{
		fwrite(SetUpdate, "TRUE!");
		fclose(SetUpdate);
	}
	printf("Done!");
	return 1;
}

#define StripNewLine StripNL
stock StripNL(str[])
{
		new
				l = strlen(str);
		while (l-- && str[l] <= ' ') str[l] = '\0';
}

stock strreplace(string[], const find[], const replace[], bool:ignorecase=false, count=cellmax, maxlength=sizeof(string)) // The real one
{
	if(isnull(find) || isnull(string)) return 0;
	new matches;
	for(new idx, flen = strlen(find), rlen = strlen(replace), pos = strfind(string, find, ignorecase); pos != -1 && idx < maxlength && matches < count; pos = strfind(string, find, ignorecase, idx))
	{
		strdel(string, pos, pos + flen);
		if(rlen) strins(string, replace, pos, maxlength);	// Crashy
		idx = pos + rlen;
		matches++;
	}
	return matches;
}

public InsertObject(objectid)
{
	printf("INSERT/UPDATE: %i", objectid);
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	printf("Error #%i\nCallback: %s\nConnectionHandle: %i", errorid, callback, connectionHandle);
	printf("Query: >%s<", query);
	printf("Error: <%s>", error);
	return 1;
}
