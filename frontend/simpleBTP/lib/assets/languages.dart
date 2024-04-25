import 'package:hive/hive.dart';

export 'languages.dart';

String selectedLang = 'it';

String getString(String key) {

  if (selectedLang == 'it') {
    return italianLang[key] ?? key;
  }
  return ''; // actually this should never happen
}

Map<String, String> italianLang = {
  // misc
  'months': 'mesi',
  'and': 'e',
  'days': 'giorni',
  // header
  'appTopBarHome': 'simpleBTP',
  'appTopBarExplore': 'Esplora',
  'appTopBarWallet': 'Portafoglio',
  // footer
  'appBottomBarHome': 'Home',
  'appBottomBarExplore': 'Esplora',
  'appBottomBarWallet': 'Portafoglio',
  'appBottomBarSettings': 'Impostazioni',
  // homepage
  'homeBalanceText': 'Il tuo investimento',
  'homeMyAssets': 'I tuoi migliori BTP',
  'homeMyAssetsViewAllButton': 'Vedi tutti',
  'homeBestBTPs': 'I BTP più performanti',
  'homeBestBTPsViewAllButton': 'Vedi tutti',
  // walletpage
  'walletBalanceText': 'Il tuo investimento',
  'walletMyAssets': 'I tuoi asset',
  'walletPaysWhat': 'Paga',
  'walletPaysIn': 'tra',
  // explorepage
  'exploreSearchPlaceholder': 'Cerca uno strumento...',
  'explorePageResults': 'Risultati',
  'explorePageOrder': 'Ordine',
  'explorePageOrderByValue': 'Valore',
  'explorePageOrderByCedola': 'Cedola',
  'explorePageOrderByExpirationDate': 'Scadenza',
  'explorePageOrderByValueButton': 'Valore di mercato',
  'explorePageOrderByCedolaButton': 'Cedola annuale',
  'explorePageOrderByExpirationDateButton': 'Data di scadenza',
  'explorePageFilterTitle': 'Personalizza la ricerca',
  'explorePageValueFilterTitle': 'Valore di mercato',
  'explorePageCedolaFilterTitle': 'Cedola annuale',
  'explorePageExpirationDateFilterTitle': 'Data di scadenza',
  'explorePageApplyFiltersButton': 'Applica',
};
