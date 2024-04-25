export 'languages.dart';

String selectedLang = '';

String getString(String key) {
  if (selectedLang == 'it') {
    return italianLang[key] ?? key;
  }
  if (selectedLang == 'en') {
    return englishLang[key] ?? key;
  }
  if (selectedLang == 'hi') {
    return hindiLang[key] ?? key;
  }
  if (selectedLang == 'ro') {
    return romanianLang[key] ?? key;
  }
  if (selectedLang == 'es') {
    return spanishLang[key] ?? key;
  }
  return ''; // actually this should never happen
}

Map<String, String> italianLang = {
  // misc
  'months': 'mesi',
  'and': 'e',
  'days': 'giorni',
  'cancel': 'Annulla',
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

Map<String, String> englishLang = {
  // misc
  'months': 'months',
  'and': 'and',
  'days': 'days',
  'cancel': 'Cancel',
  // header
  'appTopBarHome': 'simpleBTP',
  'appTopBarExplore': 'Explore',
  'appTopBarWallet': 'Wallet',
  // footer
  'appBottomBarHome': 'Home',
  'appBottomBarExplore': 'Explore',
  'appBottomBarWallet': 'Wallet',
  'appBottomBarSettings': 'Settings',
  // homepage
  'homeBalanceText': 'Your investment',
  'homeMyAssets': 'Your best BTPs',
  'homeMyAssetsViewAllButton': 'View all',
  'homeBestBTPs': 'Best performing BTPs',
  'homeBestBTPsViewAllButton': 'View all',
  // walletpage
  'walletBalanceText': 'Your investment',
  'walletMyAssets': 'Your assets',
  'walletPaysWhat': 'Pays',
  'walletPaysIn': 'in',
  // explorepage
  'exploreSearchPlaceholder': 'Search for a BTP...',
  'explorePageResults': 'Results',
  'explorePageOrder': 'Order',
  'explorePageOrderByValue': 'Price',
  'explorePageOrderByCedola': 'Coupon',
  'explorePageOrderByExpirationDate': 'Expiration',
  'explorePageOrderByValueButton': 'Market price',
  'explorePageOrderByCedolaButton': 'Yearly coupon',
  'explorePageOrderByExpirationDateButton': 'Expiration date',
  'explorePageFilterTitle': 'Customize your search',
  'explorePageValueFilterTitle': 'Market price',
  'explorePageCedolaFilterTitle': 'Yearly coupon',
  'explorePageExpirationDateFilterTitle': 'Expiration date',
  'explorePageApplyFiltersButton': 'Apply',
};

Map<String, String> hindiLang = {
  // misc
  'months': 'महीने',
  'and': 'और',
  'days': 'दिन',
  'cancel': 'रद्द करें',
  // header
  'appTopBarHome': 'होम',
  'appTopBarExplore': 'अन्वेषण',
  'appTopBarWallet': 'बटुआ',
  // footer
  'appBottomBarHome': 'होम',
  'appBottomBarExplore': 'अन्वेषण',
  'appBottomBarWallet': 'बटुआ',
  'appBottomBarSettings': 'सेटिंग्स',
  // homepage
  'homeBalanceText': 'आपका निवेश',
  'homeMyAssets': 'आपकी सर्वोत्तम BTP',
  'homeMyAssetsViewAllButton': 'सभी देखें',
  'homeBestBTPs': 'सर्वोत्तम BTP',
  'homeBestBTPsViewAllButton': 'सभी देखें',
  // walletpage
  'walletBalanceText': 'आपका निवेश',
  'walletMyAssets': 'आपके संपत्ति',
  'walletPaysWhat': 'भुगतान',
  'walletPaysIn': 'में',
  // explorepage
  'exploreSearchPlaceholder': 'किसी उपकरण की खोज करें...',
  'explorePageResults': 'परिणाम',
  'explorePageOrder': 'क्रम',
  'explorePageOrderByValue': 'मूल्य',
  'explorePageOrderByCedola': 'सेडोला',
  'explorePageOrderByExpirationDate': 'समाप्ति तिथि',
  'explorePageOrderByValueButton': 'बाजार मूल्य',
  'explorePageOrderByCedolaButton': 'वार्षिक सेडोला',
  'explorePageOrderByExpirationDateButton': 'समाप्ति तिथि',
  'explorePageFilterTitle': 'खोज को अनुकूलित करें',
  'explorePageValueFilterTitle': 'बाजार मूल्य',
  'explorePageCedolaFilterTitle': 'वार्षिक सेडोला',
  'explorePageExpirationDateFilterTitle': 'समाप्ति तिथि',
  'explorePageApplyFiltersButton': 'लागू करें',
};

Map<String, String> romanianLang = {
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

Map<String, String> spanishLang = {
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
