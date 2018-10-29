// Stripped from an old gamemode
#include <a_samp>

#define DIALOG_OBJECT_MENU		9000
#define DIALOG_OBJECT_SYSTEM	9001
#define DIALOG_OBJECT_DETAILS   9002

#include <foreach>
#include <sscanf2>

#include <a_mysql>
#include <streamer>
#include <YSI\y_timers>

new SQL_Connection;
#define SQL_Host	"localhost"
#define SQL_User	"sa-mp"
#define SQL_Pass	"F7C4Z2x1"
#define SQL_DB		"server"
SQL_Init(){mysql_debug(1); return mysql_connect(SQL_Host, SQL_User, SQL_DB, SQL_Pass);}

public OnGameModeInit()
{
	SQL_Connection = SQL_Init();
	return 1;
}

public OnGameModeExit()
{
	mysql_close(SQL_Connection);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(listitem < 0)
	{
		printf("%s\n", "<!> Player %s <%i> Is Trying to use an dialogid %i !\nlistitem = %i response: %i inputtext:", pName[playerid], playerid, dialogid, listitem, response);
		printf(inputtext);
		printf("\nLISTITEM: Error; Value may not be below Zero!");
		SendClientMessage(playerid, COLOR_ERROR, " <!> {AAAAAA}An error occurred.");
		HidePlayerDialog(playerid);
		return 1;
	}
	printf("<> Player %s <%i> Is Trying to use an dialogid %i !\nlistitem = %i response: %i inputtext:", pName[playerid], playerid, dialogid, listitem, response);
	printf(inputtext);
	printf("\n");
	switch(dialogid)
	{
		case DIALOG_OBJECT_MENU:
		{
			if(response != 1)
			{
				HidePlayerDialog(playerid);
				return 1;
			}
			new Object_Counter=GetPVarInt(playerid, "Object_Counter");
			new page_id, oQuery[460], Obj_Search[128];
			printf("Object_Counter <%i>", Object_Counter);
			if(listitem == Object_Counter) // Next Page
			{
				page_id=GetPVarInt(playerid,"Obj_Page");
				page_id++;
				SetPVarInt(playerid,"Obj_Page",page_id);
				GetPVarString(playerid,"ObjSearch", Obj_Search, sizeof(Obj_Search));
				new Obj_list=GetPVarInt(playerid,"ObjList");
				switch(Obj_list)
				{
					case 1..7:
					{
						switch(Obj_list)
						{
							case 1: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 2: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Name LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 3: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Comment LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 4: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Category LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 5: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE MTA LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 6: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE IDE LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							default: // All feilds
							{
								format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' OR Name LIKE '%%%s%%' OR Comment LIKE '%%%s%%' OR Category LIKE '%%%s%%' OR MTA LIKE '%%%s%%' OR IDE LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, Obj_Search, Obj_Search, Obj_Search, Obj_Search, Obj_Search, page_id*20);
							}
						}
						mysql_function_query(SQL_Connection, oQuery, true, "ObjectMenu", "ii", playerid, page_id);
					}
					default:
					{
						SendClientMessage(playerid, COLOR_ERROR, "Object Search System Error: PVar \"ObjList\" was not correctly set!");
						return 1;
					}
				}
				mysql_function_query(SQL_Connection, oQuery, true, "ObjectMenu", "ii", playerid, page_id);
			}
			else if(listitem == Object_Counter+1) // Previous page
			{
				page_id=GetPVarInt(playerid,"Obj_Page");
				page_id--;
				SetPVarInt(playerid,"Obj_Page",page_id);
				GetPVarString(playerid,"ObjSearch", Obj_Search, sizeof(Obj_Search));
				new Obj_list=GetPVarInt(playerid,"ObjList");
				switch(Obj_list)
				{
					case 1..7:
					{
						if(page_id*20 < 0)
						{
							SendClientMessage(playerid, COLOR_ERROR, "<!> Reached an invalid page.");
							return 1;
						}
						switch(Obj_list)
						{
							case 1: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 2: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Name LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 3: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Comment LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 4: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Category LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 5: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE MTA LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							case 6: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE IDE LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, page_id*20);
							default: // All feilds
							{
								format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' OR Name LIKE '%%%s%%' OR Comment LIKE '%%%s%%' OR Category LIKE '%%%s%%' OR MTA LIKE '%%%s%%' OR IDE LIKE '%%%s%%' LIMIT %i, 21", Obj_Search, Obj_Search, Obj_Search, Obj_Search, Obj_Search, Obj_Search, page_id*20);
							}
						}
						mysql_function_query(SQL_Connection, oQuery, true, "ObjectMenu", "ii", playerid, page_id);
					}
					default:
					{
						SendClientMessage(playerid, COLOR_ERROR, "Object Search System Error: PVar \"ObjList\" was not correctly set!");
						return 1;
					}
				}
				mysql_function_query(SQL_Connection, oQuery, true, "ObjectMenu", "ii", playerid, page_id);
			}
			else
			{
				new pVarOL[24];
				format(pVarOL, sizeof(pVarOL), "ObjectList[%i]", listitem); // Store ObjectID's
				format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model = %i", GetPVarInt(playerid, pVarOL));
				mysql_function_query(SQL_Connection, oQuery, true, "ObjectDetails", "i", playerid);
			}
			HidePlayerDialog(playerid);
		}
		case DIALOG_OBJECT_DETAILS, DIALOG_OBJECT_SYSTEM:
		{
			HidePlayerDialog(playerid);
		}
		//==============================================================================
		default:
		{
			printf("Player %s <%i> Tried to use an unknown dialogid of %i !\nlistitem = %i response: %i inputtext:", pName[playerid], playerid, dialogid, listitem, response);
			printf(inputtext); return printf("\n");
		}
	}
	HidePlayerDialog(playerid);
 	return 0;
}
//=============================================================================================//
public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	printf("SQL ERROR: %s\nConnectionHandle: %i\t\tCallback: %s\nQuery:", error, connectionHandle, callback);
	printf("%s", query);
	printf("Error ID: %i\t\tError Message:", errorid);
	printf("\t%s", error);
	return 1;
}
//=============================================================================================//

CMD:obj(playerid, params[])
{
	DeletePVar(playerid,"ObjList");
	DeletePVar(playerid,"Obj_Page");
	DeletePVar(playerid,"ObjSearch");
	new Obj_list, inputtext[128];
	if(sscanf(params, "p< >ip<|>s[127]", Obj_list, inputtext))
	{
		ShowPlayerDialog(playerid, DIALOG_OBJECT_SYSTEM, DIALOG_STYLE_MSGBOX, "Object Search", "{FFFF00}Usage: {FFFFFF}/obj {00FFFF}<type> {FF7700}<search term>\n{00FFFF}\nTypes of search:\n{FFFFFF}1 = ModelID\t(Numeric)\n2 = Name\t(String)\n3 = Comment\t(String)\n4 = Category\t(String)\n5 = MTA\t(String)\n6 = IDE\t\t(String)\n{FFFF00}7 = Match ANY Feild.", "Close", "");
		return 1;
	}
	SetPVarInt(playerid,"ObjList", Obj_list);
	// Minimum string is 3 chars
	if(inputtext[0] == '\0' || inputtext[0] == '\1' || inputtext[1] == '\0' || inputtext[1] == '\1' || inputtext[2] == '\0' || inputtext[2] == '\1' )
	{   // Raw IF's are faster than an if in a loop
		SendClientMessage(playerid, COLOR_ERROR, "Usage: /obj <search term>");
		SendClientMessage(playerid, COLOR_YELLOW, "Hint: {FFFFFF}Multiple terms not supported!");
		return 1;
	}
	if(inputtext[32] != '\0' && inputtext[32] != '\1') // 32 Chars = Maximum length
	{
		SendClientMessage(playerid, COLOR_ERROR, "Error: The specifed <search term> was too long!");
		return 1;
	}
	SetPVarString(playerid,"ObjSearch",inputtext);

	switch(Obj_list)
	{
		case 1..7:
		{
			new oQuery[460];
			switch(Obj_list)
			{
				case 1: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				case 2: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Name LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				case 3: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Comment LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				case 4: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Category LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				case 5: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE MTA LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				case 6: format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE IDE LIKE '%%%s%%' LIMIT 0, 21", inputtext);
				default: // All feilds
				{
					format(oQuery,sizeof(oQuery), "SELECT * FROM objects WHERE Model LIKE '%%%s%%' OR Name LIKE '%%%s%%' OR Comment LIKE '%%%s%%' OR Category LIKE '%%%s%%' OR MTA LIKE '%%%s%%' OR IDE LIKE '%%%s%%' LIMIT 0, 21", inputtext, inputtext, inputtext, inputtext, inputtext, inputtext);
				}
			}
			mysql_function_query(SQL_Connection, oQuery, true, "ObjectMenu", "ii", playerid, 0);
		}
		default: SendClientMessage(playerid, COLOR_ERROR, "Object Search System Error: PVar \"ObjList\" was not correctly set!");
	}
	return 1;
}
forward ObjectMenu(playerid, page_id);
// PageID starts at zero!.
public ObjectMenu(playerid, page_id)
{
	printf("\tGenerating Object List for Player: %s (%i)\n\t\tPageID: %i", pName[playerid], playerid, page_id);
	new result[64];
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows < 1)
	{
		SendClientMessage(playerid, COLOR_ERROR, ">> No objects found!");
		return 1;
	}
	new Obj_dialog[2500], Object_Counter=0;
	for(new obj_count = 0; obj_count != rows+1; obj_count++)
	{
		if(fields)
		{
			cache_get_row(obj_count, 0, result);

			if(obj_count == 20 && rows >= obj_count)
			{
				strcat(Obj_dialog, "\n{FFFFFF}Next Page");
			}else{
				if(IsNull(result)) break;
				if(strfind(result, "NULL", true) != -1) break;
				
				new pVarOL[24];
				Object_Counter++;
				format(pVarOL, sizeof(pVarOL), "ObjectList[%i]", obj_count); // Store ObjectID's
				SetPVarInt(playerid, pVarOL, strval(result));
				
				if(obj_count < rows && obj_count != 0 && obj_count < 21)
				{
					strcat(Obj_dialog, "\n{FFFFFF}");
				}
				strcat(Obj_dialog, result); // Modelid

				cache_get_row(obj_count, 1, result);
				strcat(Obj_dialog, " {00FFFF}");
				strcat(Obj_dialog, result); // Model Name

				cache_get_row(obj_count, 3, result);
				strcat(Obj_dialog, " {FFFF00}");
				strcat(Obj_dialog, result); // Category

				cache_get_row(obj_count, 5, result);
				strcat(Obj_dialog, " {00FF00}");
				strcat(Obj_dialog, result); // IDE
			}
		}
	}
	SetPVarInt(playerid, "Object_Counter", Object_Counter);
	if(page_id > 0) strcat(Obj_dialog, "\n{FFFFFF}Previous Page");
	ShowPlayerDialog(playerid, DIALOG_OBJECT_MENU, DIALOG_STYLE_LIST, "Objects List", Obj_dialog, "Continue", "Close");
	return 1;
}
forward ObjectDetails(playerid);
public ObjectDetails(playerid)
{
	new result[64];
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows < 1) return SendClientMessage(playerid, COLOR_ERROR, ">> Object not found!");
	new Obj_dialog[512];

	if(fields)
	{
		cache_get_row(0, 0, result);
		strcat(Obj_dialog, "Model ID: ");
		strcat(Obj_dialog, result); // Modelid

		cache_get_row(0, 1, result);
		strcat(Obj_dialog, "\n {00FFFF}Model Name: {FFFFFF}");
		strcat(Obj_dialog, result); // Model Name

		cache_get_row(0, 2, result);
		strcat(Obj_dialog, "\n {00FF77}Model Comment: {FFFFFF}");
		strcat(Obj_dialog, result); // Model Comment

		cache_get_row(0, 3, result);
		strcat(Obj_dialog, "\n {FFFF00}Model Category: {FFFFFF}");
		strcat(Obj_dialog, result); // Category

		cache_get_row(0, 4, result);
		strcat(Obj_dialog, "\n {FF7700}Model MTA: {FFFFFF}");
		strcat(Obj_dialog, result); // MTA

		cache_get_row(0, 5, result);
		strcat(Obj_dialog, "\n {00FF00}Model IDE: {FFFFFF}");
		strcat(Obj_dialog, result); // IDE
	}
	ShowPlayerDialog(playerid, DIALOG_OBJECT_DETAILS, DIALOG_STYLE_LIST, "Object Details", Obj_dialog, "Close", "");
	return 1;
}
