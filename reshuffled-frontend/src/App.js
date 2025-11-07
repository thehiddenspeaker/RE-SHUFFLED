import { useState } from "react";

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
      <h1 style={styles.title}>Re-Shuffled Card Creator</h1>

      <div style={styles.main}>
        <form style={styles.form} onSubmit={handleSubmit}>
          <div style={styles.card}>
            <input
              name="name"
              placeholder="Card Name"
              onChange={handleChange}
              style={styles.input}
            />
            <input
              name="mana_cost"
              placeholder="Mana Cost (e.g. (2)(B)(B))"
              onChange={handleChange}
              style={styles.input}
            />
            <div style={styles.row}>
              <select
                name="type"
                onChange={handleChange}
                value={cardData.type}
                style={{ ...styles.input, flex: 1 }}
              >
                <option value="">Select Type</option>
                <option value="Creature">Creature</option>
                <option value="Sorcery">Sorcery</option>
                <option value="Instant">Instant</option>
                <option value="Artifact">Artifact</option>
                <option value="Enchantment">Enchantment</option>
              </select>

              <input
                name="subtype"
                placeholder="Subtype"
                onChange={handleChange}
                style={{ ...styles.input, flex: 1 }}
              />
            </div>

            <select
              name="rarity"
              onChange={handleChange}
              value={cardData.rarity}
              style={styles.input}
            >
              <option value="">Select Rarity</option>
              <option value="Common">Common</option>
              <option value="Uncommon">Uncommon</option>
              <option value="Rare">Rare</option>
              <option value="Mythic">Mythic</option>
            </select>

            <textarea
              name="rules"
              placeholder="Rules Text"
              onChange={handleChange}
              style={styles.textarea}
            />
            <textarea
              name="flavor"
              placeholder="Flavor Text"
              onChange={handleChange}
              style={styles.textarea}
            />
            <input
              name="stats"
              placeholder="Power/Toughness (e.g. 3/2)"
              onChange={handleChange}
              style={styles.input}
            />

            <label style={styles.label}>Upload Card Art:</label>
            <input
              type="file"
              accept="image/*"
              onChange={handleFileChange}
              style={styles.fileInput}
            />

            <button type="submit" disabled={loading} style={styles.button}>
              {loading ? "Generating..." : "Create Card"}
            </button>
          </div>
        </form>

        <div style={styles.preview}>
          {generatedImage ? (
            <>
              <h2 style={styles.previewTitle}>Generated Card</h2>
              <img src={generatedImage} alt="Generated Card" style={styles.image} />
            </>
          ) : (
            <div style={styles.placeholder}>Your generated card will appear here</div>
          )}
        </div>
      </div>
    </div>
  );
}

const styles = {
  container: {
    fontFamily: "Inter, system-ui, sans-serif",
    background: "linear-gradient(180deg, #1a1a1d, #2e2e32)",
    color: "#f2f2f2",
    minHeight: "100vh",
    padding: "40px 20px",
    textAlign: "center",
  },
  title: {
    fontSize: "2rem",
    marginBottom: "30px",
    fontWeight: "700",
    background: "linear-gradient(90deg, #ffcc70, #ff8177)",
    WebkitBackgroundClip: "text",
    WebkitTextFillColor: "transparent",
  },
  main: {
    display: "flex",
    justifyContent: "center",
    alignItems: "flex-start",
    gap: "100px",
  },
  form: {
    display: "flex",
    justifyContent: "center",
  },
  card: {
    background: "rgba(255,255,255,0.05)",
    backdropFilter: "blur(10px)",
    borderRadius: "16px",
    padding: "30px",
    maxWidth: "480px",
    width: "100%",
    display: "flex",
    flexDirection: "column",
    gap: "12px",
    boxShadow: "0 4px 20px rgba(0,0,0,0.4)",
    height: "100%"
  },
  input: {
    padding: "10px 12px",
    borderRadius: "8px",
    border: "1px solid rgba(255,255,255,0.2)",
    background: "rgba(255,255,255,0.08)",
    color: "#fff",
    fontSize: "0.95rem",
  },
  textarea: {
    padding: "10px 12px",
    borderRadius: "8px",
    border: "1px solid rgba(255,255,255,0.2)",
    background: "rgba(255,255,255,0.08)",
    color: "#fff",
    fontSize: "0.95rem",
    minHeight: "80px",
    resize: "vertical",
  },
  row: {
    display: "flex",
    gap: "8px",
  },
  label: {
    textAlign: "left",
    marginTop: "10px",
    fontSize: "0.9rem",
    opacity: 0.8,
  },
  fileInput: {
    padding: "8px",
    background: "#222",
    borderRadius: "8px",
  },
  button: {
    marginTop: "15px",
    padding: "12px",
    borderRadius: "10px",
    border: "none",
    cursor: "pointer",
    background: "linear-gradient(90deg, #ff8177, #ffcc70)",
    color: "#000",
    fontWeight: "bold",
    fontSize: "1rem",
    transition: "all 0.3s ease",
  },
  preview: {
    background: "rgba(255,255,255,0.05)",
    borderRadius: "16px",
    padding: "20px",
    width: "400px",
    minHeight: "650px",
    boxShadow: "0 4px 20px rgba(0,0,0,0.4)",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    height: "100%"
  },
  placeholder: {
    opacity: 0.5,
    fontSize: "0.95rem",
  },
  previewTitle: {
    marginBottom: "20px",
    fontSize: "1.3rem",
  },
  image: {
    borderRadius: "12px",
    boxShadow: "0 8px 20px rgba(0,0,0,0.4)",
    width: "100%",
  },
};

export default App;
