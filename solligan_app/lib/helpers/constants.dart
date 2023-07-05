const Map<String, Map<String, String>> weatherParameters = {
  "1": {"title": "Lufttemperatur", "summary": "momentanvärde, 1 gång/tim"},
  "3": {"title": "Vindriktning", "summary": "medelvärde 10 min, 1 gång/tim"},
  "4": {"title": "Vindhastighet", "summary": "medelvärde 10 min, 1 gång/tim"},
  "6": {
    "title": "Relativ luftfuktighet",
    "summary": "momentanvärde, 1 gång/tim"
  },
  "7": {"title": "Nederbördsmängd", "summary": "summa 1 timme, 1 gång/tim"},
  "9": {
    "title": "Lufttryck",
    "summary": "vid havsytans nivå, momentanvärde, 1 gång/tim"
  },
  "10": {"title": "Solskenstid", "summary": "summa 1 timme, 1 gång/tim"},
  "11": {
    "title": "Global irradians",
    "summary": "medelvärde 1 timme, 1 gång/tim"
  },
  "12": {"title": "Sikt", "summary": "momentanvärde, 1 gång/tim"},
  "13": {
    "title": "Rådande väder",
    "summary": "momentanvärde, 1 gång/tim resp 8 gånger/dygn"
  },
  "14": {"title": "Nederbördsmängd", "summary": "summa 15 min, 4 gånger/tim"},
  "16": {"title": "Total molnmängd", "summary": "momentanvärde, 1 gång/tim"},
  "21": {"title": "Byvind", "summary": "max, 1 gång/tim"},
  "24": {
    "title": "Långvågsirradians",
    "summary": "Långvågsstrålning, medel 1 timme, varje timme"
  },
  "25": {
    "title": "Max av medelvindhastighet",
    "summary": "maximum av medelvärde 10 min, under 3 timmar, 1 gång/tim"
  },
  "28": {
    "title": "Molnbas",
    "summary": "lägsta molnlager, momentanvärde, 1 gång/tim"
  },
  "29": {
    "title": "Molnmängd",
    "summary": "lägsta molnlager, momentanvärde, 1 gång/tim"
  },
  "30": {
    "title": "Molnbas",
    "summary": "andra molnlager, momentanvärde, 1 gång/tim"
  },
  "31": {
    "title": "Molnmängd",
    "summary": "andra molnlager, momentanvärde, 1 gång/tim"
  },
  "32": {
    "title": "Molnbas",
    "summary": "tredje molnlager, momentanvärde, 1 gång/tim"
  },
  "33": {
    "title": "Molnmängd",
    "summary": "tredje molnlager, momentanvärde, 1 gång/tim"
  },
  "34": {
    "title": "Molnbas",
    "summary": "fjärde molnlager, momentanvärde, 1 gång/tim"
  },
  "35": {
    "title": "Molnmängd",
    "summary": "fjärde molnlager, momentanvärde, 1 gång/tim"
  },
  "36": {
    "title": "Molnbas",
    "summary": "lägsta molnbas, momentanvärde, 1 gång/tim"
  },
  "37": {
    "title": "Molnbas",
    "summary": "lägsta molnbas, min under 15 min, 1 gång/tim"
  },
  "38": {
    "title": "Nederbördsintensitet",
    "summary": "max av medel under 15 min, 4 gånger/tim"
  },
  "39": {
    "title": "Daggpunktstemperatur",
    "summary": "momentanvärde, 1 gång/tim"
  }
};

const List<String> monthsSwedish = [
  '',
  'januari',
  'februari',
  'mars',
  'april',
  'maj',
  'juni',
  'juli',
  'augusti',
  'september',
  'oktober',
  'november',
  'december'
];

const smhiUrlPrefix =
    'https://opendata-download-metobs.smhi.se/api/version/1.0/parameter/';
