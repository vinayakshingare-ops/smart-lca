import { db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from './firebase-config.js';

let altsList = [];

const tableBody = document.getElementById('alt-list');
const modal = document.getElementById('alt-modal');
const form = document.getElementById('alt-form');
const addBtn = document.getElementById('add-alt-btn');

async function loadAlts() {
    try {
        const querySnapshot = await getDocs(collection(db, "eco_alternatives"));
        altsList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        renderTable();
    } catch (e) {
        altsList = [{ id: 'a1', name: 'Steel Water Bottle', price: 299, ecoScoreImprovement: 60, carbonSavingsPerYear: 5.2, purchaseLink: 'https://example.com' }];
        renderTable();
    }
}

function renderTable() {
    tableBody.innerHTML = '';
    altsList.forEach(a => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${a.name}</td>
            <td>₹${a.price}</td>
            <td><span style="color: green; font-weight:bold;">+${a.ecoScoreImprovement}</span></td>
            <td>${a.carbonSavingsPerYear} kg</td>
            <td><a href="${a.purchaseLink}" target="_blank">View Link</a></td>
            <td class="actions-cell">
                <button class="btn btn-small btn-primary edit-btn" data-id="${a.id}">Edit</button>
                <button class="btn btn-small btn-danger delete-btn" data-id="${a.id}">Delete</button>
            </td>
        `;
        tableBody.appendChild(row);
    });

    document.querySelectorAll('.edit-btn').forEach(b => b.addEventListener('click', handleEdit));
    document.querySelectorAll('.delete-btn').forEach(b => b.addEventListener('click', handleDelete));
}

function openModal(a = null) {
    if (a) {
        document.getElementById('modal-title').innerText = "Edit Alternative";
        document.getElementById('a_id').value = a.id;
        document.getElementById('a_name').value = a.name;
        document.getElementById('a_price').value = a.price;
        document.getElementById('a_score').value = a.ecoScoreImprovement;
        document.getElementById('a_co2').value = a.carbonSavingsPerYear;
        document.getElementById('a_link').value = a.purchaseLink;
    } else {
        document.getElementById('modal-title').innerText = "Add Alternative";
        form.reset();
        document.getElementById('a_id').value = '';
    }
    modal.classList.add('active');
}

addBtn.addEventListener('click', () => openModal(null));
document.getElementById('close-modal').addEventListener('click', () => modal.classList.remove('active'));
document.getElementById('cancel-modal').addEventListener('click', () => modal.classList.remove('active'));

async function handleEdit(e) {
    const id = e.target.getAttribute('data-id');
    const a = altsList.find(x => x.id === id);
    if (a) openModal(a);
}

async function handleDelete(e) {
    if (!confirm("Delete this alternative?")) return;
    const id = e.target.getAttribute('data-id');
    try {
        await deleteDoc(doc(db, "eco_alternatives", id));
        loadAlts();
    } catch (err) {
        altsList = altsList.filter(x => x.id !== id);
        renderTable();
    }
}

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('a_id').value;
    const data = {
        name: document.getElementById('a_name').value,
        price: parseInt(document.getElementById('a_price').value),
        ecoScoreImprovement: parseInt(document.getElementById('a_score').value),
        carbonSavingsPerYear: parseFloat(document.getElementById('a_co2').value),
        purchaseLink: document.getElementById('a_link').value
    };

    try {
        if (id) await updateDoc(doc(db, "eco_alternatives", id), data);
        else await addDoc(collection(db, "eco_alternatives"), data);
        modal.classList.remove('active');
        loadAlts();
    } catch (err) {
        if (id) {
            const ix = altsList.findIndex(x => x.id === id);
            altsList[ix] = { id, ...data };
        } else {
            altsList.push({ id: Date.now().toString(), ...data });
        }
        renderTable();
        modal.classList.remove('active');
    }
});

loadAlts();
