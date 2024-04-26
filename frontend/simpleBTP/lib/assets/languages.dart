export 'languages.dart';

String? selectedLang = '';

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
  return ''; // actually this should never happen
}

Map<String, String> availableLanguages = {
  'it': 'Italiano',
  'en': 'English',
  'hi': 'हिन्दी',
  'ro': 'Română',
};

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
  'appTopBarSettings': 'Impostazioni',
  'appTopBarPickLanguage': 'Seleziona lingua',
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
  // settingspage
  'settingsPageAccountTitle': 'Account',
  'settingsPageWalletBackupButton': 'Backup del portafoglio',
  'settingsPageWalletBackupRestoreButton': 'Ripristino backup portafoglio',
  'settingsPageWalletDeleteButton': 'Elimina dati portafoglio',
  'settingsPagePersonalizationTitle': 'Personalizzazione',
  'settingsPageDarkModeButton': 'Modalità scura',
  'settingsPageLanguageButton': 'Seleziona lingua',
  // addBTP
  'appTopBarAddBTP': 'Aggiungi BTP',
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
  'appTopBarSettings': 'Settings',
  'appTopBarPickLanguage': 'Select language',
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
  // settingspage
  'settingsPageAccountTitle': 'Account',
  'settingsPageWalletBackupButton': 'Backup wallet',
  'settingsPageWalletBackupRestoreButton': 'Restore wallet backup',
  'settingsPageWalletDeleteButton': 'Delete wallet',
  'settingsPagePersonalizationTitle': 'Personalization',
  'settingsPageDarkModeButton': 'Dark mode',
  'settingsPageLanguageButton': 'Select language',
  // addBTP
  'appTopBarAddBTP': 'Add BTP',
  'addBTPSearchPlaceholder': 'Search for a BTP...',
  'addBTPPageResults': 'Results',
  'addBTPPageOrder': 'Order',
  'addBTPPageOrderByValue': 'Price',
  'addBTPPageOrderByCedola': 'Coupon',
  'addBTPPageOrderByExpirationDate': 'Expiration',
  'addBTPPageOrderByValueButton': 'Market price',
  'addBTPPageOrderByCedolaButton': 'Yearly coupon',
  'addBTPPageOrderByExpirationDateButton': 'Expiration date',
  'addBTPPageFilterTitle': 'Customize your search',
  'addBTPPageValueFilterTitle': 'Market price',
  'addBTPPageCedolaFilterTitle': 'Yearly coupon',
  'addBTPPageExpirationDateFilterTitle': 'Expiration date',
  'addBTPPageApplyFiltersButton': 'Apply',
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
  'appTopBarSettings': 'सेटिंग्स',
  'appTopBarPickLanguage': "यह बदलें",
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
  // settingspage
  'settingsPageAccountTitle': 'खाता',
  'settingsPageWalletBackupButton': 'बटुआ बैकअप',
  'settingsPageWalletBackupRestoreButton': 'बटुआ बैकअप बहाल करें',
  'settingsPageWalletDeleteButton': 'बटुआ हटाएं',
  'settingsPagePersonalizationTitle': 'व्यक्तिगतीकरण',
  'settingsPageDarkModeButton': 'डार्क मोड',
  'settingsPageLanguageButton': 'भाषा चुनें',
};


Map<String, String> romanianLang = {
  // misc
  'months': 'luni',
  'and': 'și',
  'days': 'zile',
  'cancel': 'Anulează',
  // header
  'appTopBarHome': 'simpleBTP',
  'appTopBarExplore': 'Explorează',
  'appTopBarWallet': 'Portofel',
  'appTopBarSettings': 'Setări',
  'appTopBarPickLanguage': 'Selectează limba',
  // footer
  'appBottomBarHome': 'Acasă',
  'appBottomBarExplore': 'Explorează',
  'appBottomBarWallet': 'Portofel',
  'appBottomBarSettings': 'Setări',
  // homepage
  'homeBalanceText': 'Investiția ta',
  'homeMyAssets': 'Cele mai bune BTP-uri',
  'homeMyAssetsViewAllButton': 'Vezi toate',
  'homeBestBTPs': 'Top BTP-uri',
  'homeBestBTPsViewAllButton': 'Vezi toate',
  // walletpage
  'walletBalanceText': 'Investiția ta',
  'walletMyAssets': 'Activele tale',
  'walletPaysWhat': 'Câștig de',
  'walletPaysIn': 'în',
  // explorepage
  'exploreSearchPlaceholder': 'Caută un BTP...',
  'explorePageResults': 'Rezultate',
  'explorePageOrder': 'Ordine',
  'explorePageOrderByValue': 'Preț',
  'explorePageOrderByCedola': 'Cupon',
  'explorePageOrderByExpirationDate': 'Expirare',
  'explorePageOrderByValueButton': 'Preț de piață',
  'explorePageOrderByCedolaButton': 'Cupon anual',
  'explorePageOrderByExpirationDateButton': 'Dată de expirare',
  'explorePageFilterTitle': 'Personalizează-ți căutarea',
  'explorePageValueFilterTitle': 'Preț de piață',
  'explorePageCedolaFilterTitle': 'Cupon anual',
  'explorePageExpirationDateFilterTitle': 'Dată de expirare',
  'explorePageApplyFiltersButton': 'Aplică',
  // settingspage
  'settingsPageAccountTitle': 'Cont',
  'settingsPageWalletBackupButton': 'Backup portofel',
  'settingsPageWalletBackupRestoreButton': 'Restaurează backup portofel',
  'settingsPageWalletDeleteButton': 'Șterge portofel',
  'settingsPagePersonalizationTitle': 'Personalizare',
  'settingsPageDarkModeButton': 'Mod întunecat',
  'settingsPageLanguageButton': 'Selectează limba',
};
