const Map<String, Map<String, String>> weatherParameters = {
  "1": {"title": "Lufttemperatur", "summary": "momentanvärde"},
  "3": {"title": "Vindriktning", "summary": "medelvärde 10 min"},
  "4": {"title": "Vindhastighet", "summary": "medelvärde 10 min"},
  "6": {"title": "Relativ luftfuktighet", "summary": "momentanvärde"},
  "7": {"title": "Nederbördsmängd", "summary": "summa 1 timme"},
  "9": {"title": "Lufttryck", "summary": "vid havsytans nivå, momentanvärde"},
  "10": {"title": "Solskenstid", "summary": "summa 1 timme"},
  "11": {"title": "Global irradians", "summary": "medelvärde 1 timme"},
  "12": {"title": "Sikt", "summary": "momentanvärde"},
  "13": {"title": "Rådande väder", "summary": "momentanvärde"},
  "16": {"title": "Total molnmängd", "summary": "momentanvärde"},
  "21": {"title": "Byvind", "summary": "max"},
  "24": {
    "title": "Långvågsirradians",
    "summary": "Långvågsstrålning, medel 1 timme"
  },
  "25": {
    "title": "Max av medelvindhastighet",
    "summary": "maximum av medelvärde 10 min, under 3 timmar"
  },
  "28": {"title": "Molnbas", "summary": "lägsta molnlager, momentanvärde"},
  "29": {"title": "Molnmängd", "summary": "lägsta molnlager, momentanvärde"},
  "30": {"title": "Molnbas", "summary": "andra molnlager, momentanvärde"},
  "31": {"title": "Molnmängd", "summary": "andra molnlager, momentanvärde"},
  "32": {"title": "Molnbas", "summary": "tredje molnlager, momentanvärde"},
  "33": {"title": "Molnmängd", "summary": "tredje molnlager, momentanvärde"},
  "34": {"title": "Molnbas", "summary": "fjärde molnlager, momentanvärde"},
  "35": {"title": "Molnmängd", "summary": "fjärde molnlager, momentanvärde"},
  "36": {"title": "Molnbas", "summary": "lägsta molnbas, momentanvärde"},
  "37": {"title": "Molnbas", "summary": "lägsta molnbas, min under 15 min"},
  "39": {"title": "Daggpunktstemperatur", "summary": "momentanvärde"}
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
