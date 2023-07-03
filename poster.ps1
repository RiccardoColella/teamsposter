$culture = New-Object System.Globalization.CultureInfo('de')
$date = (Get-Date).ToString("d._MMMM", $culture)

# Get wiki page:
$sectionsUri = "https://de.wikipedia.org/w/api.php?action=parse&format=json&page={0}&prop=sections&disabletoc=1" -f $date
$sectionsPage = Invoke-RestMethod -Method get -Uri $sectionsUri

for($i = 0; $i -lt $sectionsPage.parse.sections.length; $i++){
    if($sectionsPage.parse.sections[-$i].anchor -eq "Feier-_und_Gedenktage"){
        $feierSection = $sectionsPage.parse.sections[-$i].index
        break
    }
}

$uri = "https://de.wikipedia.org/w/api.php?action=parse&format=json&page={0}&prop=wikitext&section={1}&disabletoc=1" -f $date, $feierSection
$textOrigin = ((Invoke-RestMethod -Method get -Uri $uri).parse.wikitext."*" -Split ("----"))[0].Replace("*", "- ").Replace("[", "*").Replace("]", "*")
$text = ($textOrigin -Split " ==")[1]

$wikiURL = "https://de.wikipedia.org/wiki/{0}" -f $date
$abc = '{
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "themeColor": "0076D7",
    "summary": "Daily updates",
    "sections": [{
        "activityTitle": "Daily updates - Check out what to celebrate today!",
        "activitySubtitle": "Automated reminder",
        "activityImage": "https://cdn-icons-png.flaticon.com/512/4681/4681580.png",
        "facts": [{
            "name": "' + $date.Replace("_", " ") + '",
            "value": "' + $text + '"
        }],
        "markdown": true
    }],
    "potentialAction": [{
        "@type": "OpenUri",
        "name": "Learn More",
        "targets": [{
            "os": "default",
            "uri": "' + $wikiURL + '"
        }]
    }]
}'

$hookUrl = Get-Content -Path '.\hook.url'
#Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $abc -Uri $hookUrl
