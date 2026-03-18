import { db, collection, getDocs } from './firebase-config.js';

let usersList = [];

const tableBody = document.getElementById('users-list');

async function loadUsers() {
    try {
        const querySnapshot = await getDocs(collection(db, "users"));
        usersList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        renderTable();
    } catch (e) {
        usersList = [
            { id: 'usr_abc123', name: 'Eco Warrior', ecoCoins: 120, rank: 42 },
            { id: 'usr_xyz789', name: 'Green Citizen', ecoCoins: 85, rank: 115 },
            { id: 'usr_lmn456', name: 'Nature Lover', ecoCoins: 210, rank: 12 }
        ];
        renderTable();
    }
}

function renderTable() {
    tableBody.innerHTML = '';
    usersList.forEach(u => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td style="color: #666; font-family: monospace;">${u.id || u.userId}</td>
            <td style="font-weight: 500;">${u.name}</td>
            <td><span style="color: goldenrod; font-weight: bold;">🪙 ${u.ecoCoins}</span></td>
            <td>#${u.rank}</td>
        `;
        tableBody.appendChild(row);
    });
}

loadUsers();
