import { db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from './firebase-config.js';

let centersList = [];

const tableBody = document.getElementById('centers-list');
const modal = document.getElementById('center-modal');
const form = document.getElementById('center-form');
const addBtn = document.getElementById('add-center-btn');

async function loadCenters() {
    try {
        const querySnapshot = await getDocs(collection(db, "recycling_centers"));
        centersList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        renderTable();
    } catch (e) {
        centersList = [{ id: 'rc1', centerName: 'Swachh Pune Kabadiwala', address: 'Shivaji Nagar, Pune', acceptedMaterials: ['Plastic', 'Paper', 'Metal'], openingHours: '9:00 AM - 6:00 PM' }];
        renderTable();
    }
}

function renderTable() {
    tableBody.innerHTML = '';
    centersList.forEach(c => {
        const row = document.createElement('tr');
        const mats = Array.isArray(c.acceptedMaterials) ? c.acceptedMaterials.join(', ') : c.acceptedMaterials;
        row.innerHTML = `
            <td>${c.centerName}</td>
            <td>${c.address}</td>
            <td>${mats}</td>
            <td>${c.openingHours}</td>
            <td class="actions-cell">
                <button class="btn btn-small btn-primary edit-btn" data-id="${c.id}">Edit</button>
                <button class="btn btn-small btn-danger delete-btn" data-id="${c.id}">Delete</button>
            </td>
        `;
        tableBody.appendChild(row);
    });

    document.querySelectorAll('.edit-btn').forEach(b => b.addEventListener('click', handleEdit));
    document.querySelectorAll('.delete-btn').forEach(b => b.addEventListener('click', handleDelete));
}

function openModal(c = null) {
    if (c) {
        document.getElementById('modal-title').innerText = "Edit Center";
        document.getElementById('c_id').value = c.id;
        document.getElementById('c_name').value = c.centerName;
        document.getElementById('c_addr').value = c.address;
        document.getElementById('c_lat').value = c.latitude || 0;
        document.getElementById('c_lng').value = c.longitude || 0;
        document.getElementById('c_mat').value = Array.isArray(c.acceptedMaterials) ? c.acceptedMaterials.join(', ') : c.acceptedMaterials;
        document.getElementById('c_hours').value = c.openingHours;
    } else {
        document.getElementById('modal-title').innerText = "Add Center";
        form.reset();
        document.getElementById('c_id').value = '';
    }
    modal.classList.add('active');
}

addBtn.addEventListener('click', () => openModal(null));
document.getElementById('close-modal').addEventListener('click', () => modal.classList.remove('active'));
document.getElementById('cancel-modal').addEventListener('click', () => modal.classList.remove('active'));

async function handleEdit(e) {
    const id = e.target.getAttribute('data-id');
    const c = centersList.find(c => c.id === id);
    if (c) openModal(c);
}

async function handleDelete(e) {
    if (!confirm("Delete this center?")) return;
    const id = e.target.getAttribute('data-id');
    try {
        await deleteDoc(doc(db, "recycling_centers", id));
        loadCenters();
    } catch (err) {
        centersList = centersList.filter(c => c.id !== id);
        renderTable();
    }
}

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('c_id').value;
    const matsStr = document.getElementById('c_mat').value;
    const data = {
        centerName: document.getElementById('c_name').value,
        address: document.getElementById('c_addr').value,
        latitude: parseFloat(document.getElementById('c_lat').value),
        longitude: parseFloat(document.getElementById('c_lng').value),
        acceptedMaterials: matsStr.split(',').map(s => s.trim()),
        openingHours: document.getElementById('c_hours').value
    };

    try {
        if (id) await updateDoc(doc(db, "recycling_centers", id), data);
        else await addDoc(collection(db, "recycling_centers"), data);
        modal.classList.remove('active');
        loadCenters();
    } catch (err) {
        if (id) {
            const ix = centersList.findIndex(c => c.id === id);
            centersList[ix] = { id, ...data };
        } else {
            centersList.push({ id: Date.now().toString(), ...data });
        }
        renderTable();
        modal.classList.remove('active');
    }
});

loadCenters();
