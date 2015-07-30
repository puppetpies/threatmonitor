-- cat /tmp/thm-httpschema.txt |sort -u | sed -e 's/"//g' | sed -e 's/\[//g' | sed -e 's/\]//g' | sed -e 's/\n//g' | sed -e 's/\\n//g' | sort -u

DROP TABLE http_request;

CREATE TABLE http_request (
guid char(36),
host string,
acceptcharset string,
acceptch string,
acceptencoding string,
acceptlanguage string,
acceptlan string,
accept string,
ac string,
cachecontrol string,
charset string,
connection string,
contenttype string,
cookie string,
dnt string,
iclouddsid string,
ifmodifiedsince string,
ifnonematch string,
ifunmodifiedsince string,
keepalive string,
origin string,
pragma string,
referer string,
upgradeinsecurerequests string,
useragent string,
userage string,
usera string,
us string,
verbose string,
xapplestorefront string,
xappletz string,
xavastpro string,
xavastvbd string,
xavggms string,
xavgid string,
xavgit string,
xavgmid string,
xavgmkid string,
xavgocm string,
xavgzenid string,
xclientdata string,
xdsid string,
xflashversion string,
xgoogleupdateinteractivity string,
xhttpattempts string,
xigcapabilities string,
xlasthr string,
xlasthttpstatuscode string,
xnewrelicid string,
xnewsappsappflavour string,
xnewsappsappversion string,
xnewsappsdevicelocale string,
xnewsappsdevicetype string,
xnewsappsnetworkmcc string,
xnewsappsnetworkmnc string,
xnewsappsosplatform string,
xolduid string,
xplaybacksessionid string,
xrequestedwith string,
xretrycount string,
xwapprofile string
);
