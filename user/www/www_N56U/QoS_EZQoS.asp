<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>ASUS Wireless Router <#Web_Title#> - <#EZQoS#></title>
<link rel="stylesheet" type="text/css" href="index_style.css"> 
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
wan_route_x = '<% nvram_get_x("IPConnection", "wan_route_x"); %>';
wan_nat_x = '<% nvram_get_x("IPConnection", "wan_nat_x"); %>';
wan_proto = '<% nvram_get_x("Layer3Forwarding",  "wan_proto"); %>';

var qos_pshack 	= parseInt('<% nvram_get_x("PrinterStatus", "qos_pshack_prio"); %>');            //Game
var qos_shortpkt = parseInt('<% nvram_get_x("PrinterStatus", "qos_shortpkt_prio"); %>'); 	    //Internet
var qos_service_enable_x = parseInt('<% nvram_get_x("PrinterStatus", "qos_service_enable"); %>'); //FTP
var qos_tos = parseInt('<% nvram_get_x("PrinterStatus", "qos_tos_prio"); %>');		    //VOIP

var qosflag = [0, 0, 0, 0];
var Bar_name = ['game', 'internet', 'FTP', 'streaming'];
var qosDesp = new Array();

qosDesp[0] = "";
qosDesp[1] = "<#BM_desc1#>";
qosDesp[2] = "<#BM_desc2#>";
qosDesp[3] = "<#BM_desc3#>";
qosDesp[4] = "<#BM_desc4#>";

var qos_ubw = parseInt('<% nvram_get_x("PrinterStatus", "qos_ubw"); %>');
var qos_manual_ubw = parseInt('<% nvram_get_x("PrinterStatus", "qos_manual_ubw"); %>');
var check_hwnat = '<% check_hwnat(); %>';
var hwnat = '<% nvram_get_x("",  "hwnat"); %>';

function initial(){
	show_banner(1);
	show_menu(4, -2, 1);
	show_footer();
	
	$("statusframe").style.display = "block";
	
	with(document.form){
		qosflag[0] = qos_pshack;
		qosflag[1] = qos_shortpkt;
		qosflag[2] = qos_service_enable_x;
		qosflag[3] = qos_tos;
		
		show_all_bar();
	}
	
	openHint(16, 1);
	if(qos_ubw >= 40000 || qos_manual_ubw >= 40000){
		$('qosdespblock').innerHTML = "<span><#BM_hint#></span>";
	}
	if(document.form.qos_manual_ubw.value > "0"){
		document.form.ubw_method[1].checked = "1";
	}
	else
		document.form.ubw_method[0].checked = "1";
}

function showDescription(a, btn_obj){
	if(a > 0){ //for IE mouseover event
		$('qosdespblock').innerHTML = qosDesp[a];
		btn_obj.style.cursor = 'pointer';
	}
	else{
		$('qosdespblock').innerHTML = "<#BM_desc0#>";
		if(qos_ubw <= 40000 || qos_manual_ubw >= 40000){
			$('qosdespblock').innerHTML = "<#BM_desc0#>";
		}
	}
}

function setBW(qosnum){
	openHint(16, 1);
	if(qosflag[qosnum] == 0)
		qosflag[qosnum] = 1;
	else
		qosflag[qosnum] = 0;
	
	show_all_bar();
}

function show_all_bar(){
	$('qospipe').style.backgroundColor = '#cbdbf0';
	
	for(var i = 0; i < 4; ++i){  //Set button style
		if(qosflag[i] == 1){
			$(Bar_name[i]).style.display = 'block';
			$(Bar_name[i]+"_btn").style.background = 'url(images/band-'+(i+1)+'d.gif) no-repeat center';
		}
		else{
			$(Bar_name[i]).style.display = 'none';
			$(Bar_name[i]+"_btn").style.background = 'url(images/band-'+(i+1)+'.gif) no-repeat center';
		}
	}

	var flag_sum = qosflag[0] + qosflag[1] + qosflag[2] + qosflag[3];
	var BarPercent = 25;

	if(flag_sum != 0)
		$("qosenableblock").style.display = "";
	else
		$("qosenableblock").style.display = "none";
		
	if(qosflag[3]){ 
		BarPercent = 81/flag_sum;// when use 100/x, IE will occur wrong!
		$('p2p').style.width = "18%";
		$('p2p').title = "<#P2P_Bandwidth2#>: 10%";
		$('p2p').innerHTML = "<#P2P_Bandwidth1#> 10%";
	}
	else if(flag_sum > 0){
		$('p2p').style.width = (99 - BarPercent * flag_sum) + "%";
		$('p2p').title = "<#P2P_Priority_desc#>";
		$('p2p').innerHTML = "<#P2P_Priority#>";
	}
	else{
		$('p2p').style.width = (99 - BarPercent * flag_sum) + "%";
		$('p2p').style.display = "block";
		$('p2p').title = "<#P2P_Bandwidth2_desc#>";
		$('p2p').innerHTML = "<#P2P_Bandwidth2#>: 100%";
	}
	
	$('game').style.width = BarPercent+"%";
	$('internet').style.width = BarPercent+"%";
	$('FTP').style.width = BarPercent+"%";
	$('streaming').style.width = BarPercent+"%";
}

function submitQoS(){
	with(document.form){
		if(ubw_method[0].checked == 1)
			qos_manual_ubw.value = "";
	
		if(qosflag[0] != qos_pshack ||
				qosflag[1] != qos_shortpkt ||
				qosflag[2] != qos_service_enable_x ||
				qosflag[3] != qos_tos || 
				qos_manual_ubw.value != "<% nvram_get_x("PrinterStatus", "qos_manual_ubw"); %>"){
			
			/*if(hwnat.value == 1 && sw_mode == 1 && (qosflag[0]+qosflag[1]+qosflag[2]+qosflag[3]))
			{
				if(confirm("<#BasicConfig_HWNAT_suggestion#>"))
					hwnat.value = 0;
			}*/
				
			showLoading();
			
			if(qosflag[0]+qosflag[1]+qosflag[2]+qosflag[3]){
				qos_global_enable.value = 1;
			}
			else{
				qos_global_enable.value = 0;
			}
			
			if(qosflag[0] == 1)
				qos_pshack_prio.value = 1;
			else
				qos_pshack_prio.value = 0;
			
			if(qosflag[1] == 1)
				qos_shortpkt_prio.value = 1;
			else
				qos_shortpkt_prio.value = 0;
			
			if(qosflag[2] == 1)
				qos_service_enable.value = 1;
			else
				qos_service_enable.value = 0;
			
			if(qosflag[3] == 1)
				qos_tos_prio.value = 1;
			else
				qos_tos_prio.value = 0;
			
			action_mode.value = " Apply ";
			
			flag.value = "nodetect";
			
			submit();
		}
		else
			alert("<#BM_NoChange#>");
	}
}

function unload_body(){
	$("game_btn").onmouseover = function(){};
	$("game_btn").onmouseout = function(){};
	
	$("internet_btn").onmouseover = function(){};
	$("internet_btn").onmouseout = function(){};
	
	$("FTP_btn").onmouseover = function(){};
	$("FTP_btn").onmouseout = function(){};
	
	$("streaming_btn").onmouseover = function(){};
	$("streaming_btn").onmouseout = function(){};
}

function is_number_sp(event, o){
	keyPressed = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	if (nav)
	{
		if (	(keyPressed==8)||	// backspace
			(keyPressed==35)||	// end
			(keyPressed==36)||	// home
			(keyPressed==37)||	// <-
			(keyPressed==39)||	// ->
			(keyPressed==46)	// delete
		)
			keyPressed=0;
	}

	if (keyPressed==0)
		return true;
	if (keyPressed>47 && keyPressed<58)
	{
		if (keyPressed==48 && o.length == 0) return false;
		return true;
	}
	else
	{
		return false;
	}
}
</script>
</head>

<body onload="initial();" onunload="unload_body();">
<div id="TopBanner"></div>

<div id="Loading" class="popup_bg"></div>
<!--for uniform show, useless but have exist-->
<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get_x("LANGUAGE", "preferred_lang"); %>">
<input type="hidden" name="wl_ssid2" value="<% nvram_get_x("WLANConfig11b",  "wl_ssid2"); %>">
<input type="hidden" name="firmver" value="<% nvram_get_x("",  "firmver"); %>">

<input type="hidden" name="current_page" value="/QoS_EZQoS.asp">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="sid_list" value="PrinterStatus;">
<input type="hidden" name="group_id" value="">
<input type="hidden" name="action_mode" value="">

<input type="hidden" name="hwnat" value="<% nvram_get_x("PrinterStatus","hwnat"); %>">
<input type="hidden" name="flag" value="">

<input type='hidden' name='qos_global_enable'>
<input type='hidden' name='qos_pshack_prio'> <!-- Game -->
<input type='hidden' name='qos_shortpkt_prio'><!-- Internet -->
<input type='hidden' name='qos_service_enable'><!-- FTP -->
<input type='hidden' name='qos_tos_prio'><!-- VOIP -->
<table class="content" align="center" cellpadding="0" cellspacing="0">
  <tr>
	<td width="23">&nbsp;</td>
	
	<!--=====Beginning of Main Menu=====-->
	<td valign="top" width="202">
	  <div id="mainMenu"></div>
	  <div id="subMenu"></div>
	</td>
	
    <td valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
		<br>
		<!--===================================Beginning of Main Content===========================================-->
<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td valign="top" align="center">
		    <br/>
			<!--div class="bandtext"><#Bandwidth#></div-->
			<div id="qospipe">				
				<div class="qosbar" id="game"><#Game#></div>
				<div class="qosbar" id="internet"><#Internet#></div>
				<div class="qosbar" id="FTP">FTP</div>
				<div class="qosbar" id="streaming"><#Stream#></div>
				<div id="p2p"><#NoQoSsetting#></div>
			</div>

			<div id="qosbox">
				<table width="400" border="0" cellspacing="0" cellpadding="0">
					<tr align="center">
						<td id="game_btn" width="100" class="qosbutton1" onmouseover="showDescription(1, this);" onmouseout="showDescription(0, this);" onclick="setBW(0);"><a href="#"></a></td>
						<td id="internet_btn" width="100" class="qosbutton2" onmouseover="showDescription(2, this);" onmouseout="showDescription(0, this);" onclick="setBW(1);"><a href="#"></a></td>
						<td id="FTP_btn" width="100" class="qosbutton3" onmouseover="showDescription(3, this);" onmouseout="showDescription(0, this);" onclick="setBW(2);"><a href="#"></a></td>
						<td id="streaming_btn" width="100" class="qosbutton4" onmouseover="showDescription(4, this);" onmouseout="showDescription(0, this);" onclick="setBW(3);"><a href="#"></a></td>
					</tr>

					<tr>
						<td width="25%" class="band"><#BM_GB#></td>
						<td width="25%" class="band"><#BM_IA#></td>
						<td width="25%" class="band"><#BM_FTPS#></td>
						<td width="25%" class="band"><#BM_VVS#></td>
					</tr>
				</table>

				<div id="qosdespblock"><#BM_desc0#></div>
			</div>
			
			<div id="qosenableblock">
				<input type="radio" name="ubw_method" value="0" onClick="openHint(20, 1);">
        <a class="hintstyle" href="javascript:void(0);" onClick="openHint(20, 1);"><#BM_measured_uplink_speed#></a>
				<span id="qos_ubw"><% nvram_get_x("PrinterStatus", "qos_ubw"); %> Kb/s</span><br>
				<input type="radio" name="ubw_method" value="1" onClick="openHint(20, 2);">
        	<a class="hintstyle" href="javascript:void(0);" onClick="openHint(20, 2);"><#BM_manual_uplink_speed#></a>
				<input type="text" maxlength="10" name="qos_manual_ubw" onKeyPress="return is_number_sp(event, this);" class="input" size="8" value="<% nvram_get_x("PrinterStatus", "qos_manual_ubw"); %>"> Kb/s
			</div>

			<div class="apply1"><a href="javascript:submitQoS();"><#CTL_onlysave#></a></div>
	</td>
	
					
					<!--==============Beginning of hint content=============-->
					<td id="help_td" style="width:15px;" valign="top">
						<form name="hint_form"></form>
						<div id="helpicon" onClick="openHint(0,0);" title="Click to open AiHelp"><img src="images/help.gif" /></div>
						<div id="hintofPM" style="display:none;">
							<table width="100%" cellpadding="0" cellspacing="1" class="Help" bgcolor="#999999">
								<thead>
								<tr>
									<td>
										<div id="helpname" class="AiHintTitle"></div>
									</td>
								</tr>
								</thead>
								
								<tr>
									<td valign="top">
										<div class="hint_body2" id="hint_body"></div>
										<iframe id="statusframe" name="statusframe" class="statusframe" src="" frameborder="0"></iframe>
									</td>
								</tr>
							</table>
						</div>
					</td>
					<!--==============Ending of hint content=============-->
					
				</tr>
			</table>				
		</td>
		
    <td width="10" align="center" valign="top">&nbsp;</td>
	</tr>
</table>

<div id="footer"></div>
</body>
</html>
