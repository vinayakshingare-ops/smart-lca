import { db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from './firebase-config.js';

let productsList = [];

const tableBody = document.getElementById('products-list');
const modal = document.getElementById('product-modal');
const form = document.getElementById('product-form');
const addBtn = document.getElementById('add-product-btn');
const closeBtn = document.getElementById('close-modal');
const cancelBtn = document.getElementById('cancel-modal');

async function loadProducts() {
    try {
        const querySnapshot = await getDocs(collection(db, "products"));
        productsList = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        renderTable();
    } catch (e) {
        console.warn("Using mock data as Firebase is not configured");
        productsList = [{ id: 'p1', name: 'Plastic Water Bottle', barcode: '123456789', materialType: 'PET', ecoScore: 30, carbonImpact: 0.3 }];
        renderTable();
    }
}

function renderTable() {
    tableBody.innerHTML = '';
    if (productsList.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="6" style="text-align:center;">No products found</td></tr>';
        return;
    }

    productsList.forEach(p => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${p.name || ''}</td>
            <td>${p.barcode || ''}</td>
            <td>${p.materialType || ''}</td>
            <td><span style="color: green; font-weight:bold;">${p.ecoScore || 0}</span></td>
            <td>${p.carbonImpact || 0}</td>
            <td class="actions-cell">
                <button class="btn btn-small btn-primary edit-btn" data-id="${p.id}">Edit</button>
                <button class="btn btn-small btn-danger delete-btn" data-id="${p.id}">Delete</button>
            </td>
        `;
        tableBody.appendChild(row);
    });

    // Attach listeners
    document.querySelectorAll('.edit-btn').forEach(b => b.addEventListener('click', handleEdit));
    document.querySelectorAll('.delete-btn').forEach(b => b.addEventListener('click', handleDelete));
}

function openModal(prod = null) {
    if (prod) {
        document.getElementById('modal-title').innerText = "Edit Product";
        document.getElementById('p_id').value = prod.id;
        document.getElementById('p_name').value = prod.name || '';
        document.getElementById('p_barcode').value = prod.barcode || '';
        document.getElementById('p_material').value = prod.materialType || '';
        document.getElementById('p_score').value = prod.ecoScore || 0;
        document.getElementById('p_co2').value = prod.carbonImpact || 0;
        document.getElementById('p_inst_en').value = prod.recyclingInstructionsEn || '';
        document.getElementById('p_inst_hi').value = prod.recyclingInstructionsHi || '';
    } else {
        document.getElementById('modal-title').innerText = "Add New Product";
        form.reset();
        document.getElementById('p_id').value = '';
    }
    modal.classList.add('active');
}

function closeModal() {
    modal.classList.remove('active');
}

addBtn.addEventListener('click', () => openModal());
closeBtn.addEventListener('click', closeModal);
cancelBtn.addEventListener('click', closeModal);

async function handleEdit(e) {
    const id = e.target.getAttribute('data-id');
    const prod = productsList.find(p => p.id === id);
    if (prod) openModal(prod);
}

async function handleDelete(e) {
    if (!confirm("Delete this product?")) return;
    const id = e.target.getAttribute('data-id');
    try {
        await deleteDoc(doc(db, "products", id));
        loadProducts();
    } catch (e) {
        alert("Action simulated! Update Firebase config to actually delete.");
        // Mock delete
        productsList = productsList.filter(p => p.id !== id);
        renderTable();
    }
}

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('p_id').value;
    const data = {
        name: document.getElementById('p_name').value,
        barcode: document.getElementById('p_barcode').value,
        materialType: document.getElementById('p_material').value,
        ecoScore: parseInt(document.getElementById('p_score').value),
        carbonImpact: parseFloat(document.getElementById('p_co2').value),
        recyclingInstructionsEn: document.getElementById('p_inst_en').value,
        recyclingInstructionsHi: document.getElementById('p_inst_hi').value
    };

    try {
        if (id) {
            await updateDoc(doc(db, "products", id), data);
        } else {
            await addDoc(collection(db, "products"), data);
        }
        closeModal();
        loadProducts();
    } catch (err) {
        alert("Action simulated! Update Firebase config to actually save.");
        if (id) {
            const ix = productsList.findIndex(p => p.id === id);
            productsList[ix] = { id, ...data };
        } else {
            productsList.push({ id: Date.now().toString(), ...data });
        }
        renderTable();
        closeModal();
    }
});

loadProducts();
