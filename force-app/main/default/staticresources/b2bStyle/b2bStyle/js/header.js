// <script type="text/javascript" src="/sfsites/c/resource/b2bStyle/js/header.js" defer></script>
window.addEventListener('click', (event) => {
    let root = document.documentElement;
    if (root) {
        if (window.innerWidth < 768) {
            let menu = document.querySelector('community_navigation-drilldown-navigation-list');
            if (menu) {
                root.style.setProperty('--b2b-guest-cart-icon-button-z-index-mobile', '-1');
            } else {
                root.style.setProperty('--b2b-guest-cart-icon-button-z-index-mobile', '999');
            }
        }
    }
});