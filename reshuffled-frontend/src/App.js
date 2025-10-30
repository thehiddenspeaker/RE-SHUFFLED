import  { useState } from "react";

function App() {
  const [cardData, setCardData] = useState({
    name: "",
    mana_cost: "",
    type: "",
    subtype: "",
    rarity: "",
    rules: "",
    flavor: "",
    stats: "",
  });
  const [artFile, setArtFile] = useState(null);
  const [generatedImage, setGeneratedImage] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setCardData({ ...cardData, [e.target.name]: e.target.value });
  };

  const handleFileChange = (e) => {
    setArtFile(e.target.files[0]);
  };

  const handleSubmit = async (e) => {
  e.preventDefault();
  if (!artFile) {
    alert("Please upload an image file.");
    return;
  }

  setLoading(true);
  setGeneratedImage(null);

  const formData = new FormData();
  formData.append("name", cardData.name);
  formData.append("manaCost", cardData.mana_cost);
  formData.append("type", cardData.type);
  formData.append("subType", cardData.subtype); 
  formData.append("rarity", cardData.rarity);
  formData.append("rules", cardData.rules);
  formData.append("flavor", cardData.flavor);
  formData.append("stats", cardData.stats);
  formData.append("art", artFile);

  try {
    const response = await fetch("http://localhost:4567/generate_card", {
      method: "POST",
      body: formData,
    });

    const data = await response.json();
    if (data.success) {
      setGeneratedImage(data.image_path); 
    } else {
      alert("Failed to generate card.");
    }
  } catch (err) {
    console.error(err);
    alert("Error connecting to backend: " + err);
  } finally {
    setLoading(false);
  }
};

  return (
    <div style={styles.container}>
      <h1>Re-Shuffled Card Creator</h1>
      <form style={styles.form} onSubmit={handleSubmit}>
        <input name="name" placeholder="Card Name" onChange={handleChange} />
        <input name="mana_cost" placeholder="Mana Cost" onChange={handleChange} />
        <input name="type" placeholder="Type (e.g. Creature)" onChange={handleChange} />
        <input name="subtype" placeholder="Subtype" onChange={handleChange} />
        <input name="rarity" placeholder="Rarity" onChange={handleChange} />
        <textarea name="rules" placeholder="Rules Text" onChange={handleChange}></textarea>
        <textarea name="flavor" placeholder="Flavor Text" onChange={handleChange}></textarea>
        <input name="stats" placeholder="Power/Toughness (e.g. 3/2)" onChange={handleChange} />

        <label>Upload Card Art:</label>
        <input type="file" accept="image/*" onChange={handleFileChange} />

        <button type="submit" disabled={loading}>
          {loading ? "Generating..." : "Create Card"}
        </button>
      </form>

      {generatedImage && (
        <div style={styles.preview}>
          <h2>Generated Card</h2>
          <img src={generatedImage} alt="Generated Card" style={styles.image} />
        </div>
      )}
    </div>
  );
}

const styles = {
  container: {
    fontFamily: "system-ui, sans-serif",
    padding: "20px",
    textAlign: "center",
    background: "#f7f7f7",
    minHeight: "100vh",
  },
  form: {
    display: "grid",
    gap: "10px",
    maxWidth: "400px",
    margin: "0 auto",
  },
  preview: {
    marginTop: "30px",
  },
  image: {
    borderRadius: "12px",
    boxShadow: "0 4px 10px rgba(0,0,0,0.3)",
    width: "400px",
  },
};

export default App;
