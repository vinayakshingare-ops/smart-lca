// scripts/import_products.js
// 1. Run `npm init -y` and `npm install firebase-admin` in this directory.
// 2. Download your Firebase service account key as `serviceAccountKey.json`.
// 3. Run `node import_products.js`

const admin = require('firebase-admin');

// Initialize Firebase Admin
// const serviceAccount = require('./serviceAccountKey.json');
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// Using default application credentials for now (if running in GCP/Firebase environment)
// or uncomment above to use a downloaded key.
try {
  admin.initializeApp();
} catch (e) {
  console.log('Please configure Firebase Admin credentials.');
  process.exit(1);
}

const db = admin.firestore();

const products = [
  {
    id: "p1",
    name_en: "Bamboo Straw Set",
    name_hi: "बांस के स्ट्रॉ का सेट",
    image_url: "https://images.unsplash.com/photo-1590753239841-f62fbcaecc23?auto=format&fit=crop&w=400&q=80",
    eco_score: "A++",
    lca_summary: "Zero plastic, reusable 1yr",
    price: 150,
    category: "Utensils",
    carbon_saved: 2.5,
    stock: 100
  },
  {
    id: "p2",
    name_en: "Stainless Steel Bottle (Bambrew)",
    name_hi: "स्टेनलेस स्टील की बोतल",
    image_url: "https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Steel vs plastic: 90% less CO2",
    price: 800,
    category: "Bottles",
    carbon_saved: 5.0,
    stock: 50
  },
  {
    id: "p3",
    name_en: "Jute Shopping Bag",
    name_hi: "जूट शॉपिंग बैग",
    image_url: "https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80",
    eco_score: "A+",
    lca_summary: "Biodegradable, 1000x reusable",
    price: 200,
    category: "Bags",
    carbon_saved: 4.2,
    stock: 150
  },
  {
    id: "p4",
    name_en: "Cotton Reusable Cloth Bags (set of 5)",
    name_hi: "कॉटन के कपड़े के बैग (5 का सेट)",
    image_url: "https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Reusable hundreds of times",
    price: 300,
    category: "Bags",
    carbon_saved: 3.8,
    stock: 200
  },
  {
    id: "p5",
    name_en: "Wooden Toothbrush",
    name_hi: "लकड़ी का टूथब्रश",
    image_url: "https://images.unsplash.com/photo-1606131336048-52c66d9f6ed3?auto=format&fit=crop&w=400&q=80",
    eco_score: "A++",
    lca_summary: "Compostable handle",
    price: 100,
    category: "Personal Care",
    carbon_saved: 0.8,
    stock: 300
  },
  {
    id: "p6",
    name_en: "Clay Kulhad Cups (pack 10)",
    name_hi: "मिट्टी के कुल्हड़ (10 का पैक)",
    image_url: "https://images.unsplash.com/photo-1590753239841-f62fbcaecc23?auto=format&fit=crop&w=400&q=80",
    eco_score: "A+",
    lca_summary: "No plastic waste, natural earth",
    price: 250,
    category: "Utensils",
    carbon_saved: 1.5,
    stock: 80
  },
  {
    id: "p7",
    name_en: "Beeswax Food Wraps",
    name_hi: "मधुमक्खी के मोम के फूड रैप्स",
    image_url: "https://images.unsplash.com/photo-1590753239841-f62fbcaecc23?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Replaces cling film",
    price: 400,
    category: "Kitchen",
    carbon_saved: 2.2,
    stock: 60
  },
  {
    id: "p8",
    name_en: "Stainless Steel Straws",
    name_hi: "स्टेनलेस स्टील के स्ट्रॉ",
    image_url: "https://images.unsplash.com/photo-1590753239841-f62fbcaecc23?auto=format&fit=crop&w=400&q=80",
    eco_score: "A++",
    lca_summary: "Lifetime reusable",
    price: 120,
    category: "Utensils",
    carbon_saved: 3.0,
    stock: 120
  },
  {
    id: "p9",
    name_en: "Hemp Tote Bag",
    name_hi: "भांग का टोट बैग",
    image_url: "https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Low water footprint material",
    price: 350,
    category: "Bags",
    carbon_saved: 4.5,
    stock: 90
  },
  {
    id: "p10",
    name_en: "Bamboo Toothbrush Pack",
    name_hi: "बांस के टूथब्रश का पैक",
    image_url: "https://images.unsplash.com/photo-1606131336048-52c66d9f6ed3?auto=format&fit=crop&w=400&q=80",
    eco_score: "A++",
    lca_summary: "Family pack, zero plastic",
    price: 180,
    category: "Personal Care",
    carbon_saved: 1.2,
    stock: 400
  },
  {
    id: "p11",
    name_en: "Reusable Silicone Food Bags",
    name_hi: "दोबारा इस्तेमाल होने वाले सिलिकॉन बैग",
    image_url: "https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Replaces Ziplocs securely",
    price: 500,
    category: "Kitchen",
    carbon_saved: 5.5,
    stock: 50
  },
  {
    id: "p12",
    name_en: "Copper Water Bottle",
    name_hi: "तांबे की पानी की बोतल",
    image_url: "https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=400&q=80",
    eco_score: "A+",
    lca_summary: "Ayurvedic health + eco",
    price: 1200,
    category: "Bottles",
    carbon_saved: 8.0,
    stock: 30
  },
  {
    id: "p13",
    name_en: "Organic Cotton T-Shirts",
    name_hi: "ऑर्गेनिक कॉटन टी-शर्ट",
    image_url: "https://images.unsplash.com/photo-1597484661643-2f5fef640df1?auto=format&fit=crop&w=400&q=80",
    eco_score: "B+",
    lca_summary: "Pesticide-free farming",
    price: 600,
    category: "Clothing",
    carbon_saved: 6.0,
    stock: 150
  },
  {
    id: "p14",
    name_en: "Recycled Paper Notebooks",
    name_hi: "रीसाइकल किए गए कागज की नोटबुक",
    image_url: "https://images.unsplash.com/photo-1606131336048-52c66d9f6ed3?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Saves trees directly",
    price: 250,
    category: "Stationery",
    carbon_saved: 2.0,
    stock: 200
  },
  {
    id: "p15",
    name_en: "Solar Phone Charger",
    name_hi: "सोलर फोन चार्जर",
    image_url: "https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=400&q=80",
    eco_score: "A",
    lca_summary: "Renewable energy on the go",
    price: 1500,
    category: "Electronics",
    carbon_saved: 10.0,
    stock: 25
  },
  // Placeholders
  { id: "p16", name_en: "Placeholder 1", name_hi: "प्लेसहोल्डर 1", image_url: "", eco_score: "B", lca_summary: "TBD", price: 100, category: "Other", carbon_saved: 0, stock: 0 },
  { id: "p17", name_en: "Placeholder 2", name_hi: "प्लेसहोल्डर 2", image_url: "", eco_score: "B", lca_summary: "TBD", price: 100, category: "Other", carbon_saved: 0, stock: 0 },
  { id: "p18", name_en: "Placeholder 3", name_hi: "प्लेसहोल्डर 3", image_url: "", eco_score: "B", lca_summary: "TBD", price: 100, category: "Other", carbon_saved: 0, stock: 0 },
  { id: "p19", name_en: "Placeholder 4", name_hi: "प्लेसहोल्डर 4", image_url: "", eco_score: "B", lca_summary: "TBD", price: 100, category: "Other", carbon_saved: 0, stock: 0 },
  { id: "p20", name_en: "Placeholder 5", name_hi: "प्लेसहोल्डर 5", image_url: "", eco_score: "B", lca_summary: "TBD", price: 100, category: "Other", carbon_saved: 0, stock: 0 },
];

async function importData() {
  const collectionRef = db.collection('eco_products');
  let count = 0;
  for (const product of products) {
    try {
      await collectionRef.doc(product.id).set(product);
      console.log(`Imported ${product.name_en}`);
      count++;
    } catch (e) {
      console.error(`Failed to import ${product.name_en}: `, e);
    }
  }
  console.log(`Successfully imported ${count} products.`);
}

importData();
