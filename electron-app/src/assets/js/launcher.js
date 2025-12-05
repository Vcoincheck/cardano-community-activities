document.addEventListener('DOMContentLoaded', () => {
    const endUserCard = document.getElementById('endUserCard');
    const adminCard = document.getElementById('adminCard');

    endUserCard.querySelector('button').addEventListener('click', () => {
        window.electronAPI.navigate('end-user');
    });

    adminCard.querySelector('button').addEventListener('click', () => {
        window.electronAPI.navigate('admin');
    });
});
