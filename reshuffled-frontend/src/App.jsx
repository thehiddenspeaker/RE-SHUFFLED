import { useState } from "react";
import NavBar from "./components/navbar";
import {
	Container,
	Group,
	SimpleGrid,
	TextInput,
	Title,
	Textarea,
	Button,
	Paper,
	Notification,
	Text,
	ActionIcon,
	FileButton,
	Stack,
	Flex,
	Card,
} from "@mantine/core";
import {
	IconX,
	IconCheck,
	IconFileTypeJpg,
	IconFileTypePng,
	IconArrowBack,
} from "@tabler/icons-react";
import "./App.css";

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
	const [artPreview, setArtPreview] = useState(null);
	const [imageUrl, setImageUrl] = useState("");
	const [loading, setLoading] = useState(false);
	const [notification, setNotification] = useState(null);
	const [generatedImage, setGeneratedImage] = useState(null);

	const handleChange = (value, field) => {
		setCardData({ ...cardData, [field]: value });
	};

	const handleFileChange = (file) => {
		setArtFile(file);

		if (file) {
			const reader = new FileReader();
			reader.onloadend = () => {
				setArtPreview(reader.result);
			};
			reader.readAsDataURL(file);
		}
	};

	const handleUrlChange = (value) => {
		setImageUrl(value);
		setArtFile(null);

		if (value) {
			setArtPreview(value);
		}
	};

	const handleSubmit = async () => {
		if (!artFile && !imageUrl) {
			setNotification({
				type: "error",
				message: "Please upload an image or provide an image URL!",
			});
			return;
		}

		setLoading(true);

		const formData = new FormData();
		formData.append("name", cardData.name);
		formData.append("manaCost", cardData.mana_cost);
		formData.append("type", cardData.type);
		formData.append("subType", cardData.subtype);
		formData.append("rarity", cardData.rarity);
		formData.append("rules", cardData.rules);
		formData.append("flavor", cardData.flavor);
		formData.append("stats", cardData.stats);
		if (artFile) {
			formData.append("art", artFile);
		} else if (imageUrl) {
			formData.append("imageUrl", imageUrl);
		}

		try {
			const response = await fetch("http://localhost:3001/generate_card", {
				method: "POST",
				body: formData,
			});

			const data = await response.json();
			if (data.success) {
				setGeneratedImage(data.image_path);
				// setNotification({
				// 	type: "success",
				// 	message: "Card generated successfully!",
				// });
			} else {
				setNotification({
					type: "error",
					message: "Failed to generate card.",
				});
			}
		} catch (err) {
			console.error(err);
			setNotification({
				type: "error",
				message: `Error connecting to backend: ${err.message}`,
			});
		} finally {
			setLoading(false);
		}
	};

	const handleDownload = async (format) => {
		if (!generatedImage) {
			setNotification({
				type: "error",
				message: "No card to download. Please generate a card first.",
			});
			return;
		}

		try {
			const url = new URL(generatedImage);
			const pathname = url.pathname;
			const filename = pathname.split("/").pop().split("?")[0];

			const response = await fetch(
				`http://localhost:3001/download/${filename}/${format}`
			);
			const data = await response.json();

			if (data.success) {
				// const fileUrl = `http://localhost:3001${data.download_path}`;
				// const fileBlob = await fetch(fileUrl);
				// const blob = await fileBlob.blob();

				// const blobUrl = window.URL.createObjectURL(blob);
				const link = document.createElement("a");
				link.href = `http://localhost:3001${data.download_path}`;
				link.download = `${cardData.name || "card"}.${format}`;
				link.setAttribute("target", "_blank");
				document.body.appendChild(link);
				link.click();
				document.body.removeChild(link);
				// window.URL.revokeObjectURL(blobUrl);

				setNotification({
					type: "success",
					message: `Card downloaded as ${format.toUpperCase()}!`,
				});
			} else {
				throw new Error(data.error);
			}
		} catch (err) {
			setNotification({
				type: "error",
				message: "Failed to download card.",
			});
		}
	};

	// Card Reset
	const resetForm = () => {
		setCardData({
			name: "",
			mana_cost: "",
			type: "",
			subtype: "",
			rarity: "",
			rules: "",
			flavor: "",
			stats: "",
		});
		setArtFile(null);
		setArtPreview(null);
		setImageUrl("");
		setGeneratedImage(null);
		setNotification(null);
	};

	return (
		<>
			<NavBar />

			{notification && (
				<div style={{ position: "fixed", top: 70, right: 20, zIndex: 1000 }}>
					<Notification
						icon={
							notification.type === "success" ? (
								<IconCheck size={20} />
							) : (
								<IconX size={20} />
							)
						}
						color={notification.type === "success" ? "teal" : "red"}
						title={notification.type === "success" ? "Yay!" : "Bummer!"}
						onClose={() => setNotification(null)}
					>
						{notification.message}
					</Notification>
				</div>
			)}

			<SimpleGrid
				cols={2}
				spacing="xs"
				verticalSpacing="xs"
				className="container"
			>
				<div className="form-section">
					<Title order={2} p="md" ta="center" className="titles">
						Create a Magic: The Gathering Card
					</Title>

					<Container>
						<Group mb="md" grow>
							<TextInput
								label="Card Name"
								placeholder="Enter card name"
								value={cardData.name}
								onChange={(e) => handleChange(e.target.value, "name")}
							/>
							<TextInput
								label="Mana Cost"
								placeholder="e.g., (3)(U)"
								value={cardData.mana_cost}
								onChange={(e) => handleChange(e.target.value, "mana_cost")}
							/>
						</Group>

						<Group mb="md" grow>
							<TextInput
								label="Type"
								value={cardData.type}
								onChange={(e) => handleChange(e.target.value, "type")}
								placeholder="e.g., Creature"
							/>
							<TextInput
								label="Subtype"
								value={cardData.subtype}
								onChange={(e) => handleChange(e.target.value, "subtype")}
								placeholder="e.g., Human Wizard"
							/>
							<TextInput
								label="Rarity"
								value={cardData.rarity}
								onChange={(e) => handleChange(e.target.value, "rarity")}
								placeholder="e.g., Rare"
							/>
						</Group>
						<Textarea
							label="Rules Text"
							placeholder="Enter card abilities and rules"
							value={cardData.rules}
							onChange={(e) => handleChange(e.target.value, "rules")}
							minRows={2}
							mb="md"
						/>

						<Textarea
							label="Flavor Text"
							placeholder="Optional flavor text"
							value={cardData.flavor}
							onChange={(e) => handleChange(e.target.value, "flavor")}
							minRows={2}
							mb="md"
						/>
						<TextInput
							label="Stats"
							placeholder="e.g., 3/2"
							value={cardData.stats}
							onChange={(e) => handleChange(e.target.value, "stats")}
							mb="md"
						/>

						<Paper
							p="lg"
							radius="md"
							style={{
								borderStyle: "dashed",
								borderColor: "#d4b896",
								background: "#fafaf8",
								textAlign: "center",
							}}
							withBorder
						>
							<Group gap="md" wrap="nowrap" justify="center">
								<Stack style={{ padding: "0.07rem" }}>
									<FileButton
										accept="image/*"
										onChange={handleFileChange}
										disabled={!!imageUrl}
									>
										{(props) => (
											<Button
												{...props}
												style={{
													background:
														"linear-gradient(135deg, #d4762e 0%, #b85e1f 100%",
													border: "none",
												}}
											>
												Upload Image
											</Button>
										)}
									</FileButton>

									{artFile && (
										<Text size="sm" ta="center" c="dimmed">
											{artFile.name}
										</Text>
									)}
								</Stack>
								<Text size="sm" ta="center" c="dimmed">
									OR
								</Text>
								<TextInput
									placeholder="Provide image URL..."
									value={imageUrl}
									onChange={(e) => handleUrlChange(e.target.value)}
									disabled={!!artFile}
								/>
							</Group>
						</Paper>

						<Button
							loading={loading}
							fullWidth
							size="lg"
							radius="md"
							onClick={handleSubmit}
							style={{
								background: "linear-gradient(135deg, #2c7a3e 0%, #1f5a2c 100%)",
								marginTop: "1rem",
							}}
						>
							Generate Final Card
						</Button>
					</Container>
				</div>

				<div style={styles.previewContainer}>
					<Card
						shadow="xl"
						padding="0.5rem 2.5rem 2.5rem 2.5rem"
						radius="lg"
						style={{ background: "white" }}
					>
						<Title order={2} p="md" ta="center" className="titles">
							{generatedImage ? "Generated Card" : "Card Preview"}
						</Title>

						{generatedImage ? (
							<>
								<img
									src={generatedImage}
									alt="Generated Card"
									style={styles.image}
								/>

								<Group className="utility-section">
									<ActionIcon
										variant="filed"
										size="xl"
										aria-label="Reset"
										onClick={resetForm}
									>
										<IconArrowBack
											style={{ width: "70%", height: "70%" }}
											stroke={1.5}
										/>
									</ActionIcon>
									<ActionIcon
										variant="filled"
										size="xl"
										aria-label="Download as PNG"
										onClick={() => handleDownload("png")}
									>
										<IconFileTypePng
											style={{ width: "70%", height: "70%" }}
											stroke={1.5}
										/>
									</ActionIcon>
									<ActionIcon
										variant="filled"
										size="xl"
										aria-label="Download as JPG"
										onClick={() => handleDownload("jpg")}
									>
										<IconFileTypeJpg
											style={{ width: "70%", height: "70%" }}
											stroke={1.5}
										/>
									</ActionIcon>
								</Group>
							</>
						) : (
							<div style={styles.card}>
								<div style={styles.cardHeader}>
									<div style={styles.cardName}>
										{cardData.name || "Untitled"}
									</div>
									<div style={styles.manaCost}>{cardData.mana_cost || "0"}</div>
								</div>

								{/* Card Art */}
								<div style={styles.cardArt}>
									{artPreview ? (
										<img
											src={artPreview}
											alt="Card art"
											style={styles.artImage}
										/>
									) : (
										<div style={styles.artPlaceholder}>
											Upload image to preview
										</div>
									)}
								</div>

								{/* Type Line */}
								<div style={styles.typeLine}>
									{cardData.type && cardData.subtype
										? `${cardData.type} — ${cardData.subtype}`
										: cardData.type || "Type"}
								</div>

								{/* Rules Text */}
								<div style={styles.rulesBox}>
									<div style={styles.rulesText}>
										{cardData.rules || "Rules text will appear here"}
									</div>
									{cardData.flavor && (
										<div style={styles.flavorText}>
											<em>{cardData.flavor}</em>
										</div>
									)}
								</div>

								{/* Bottom Section */}
								<div style={styles.cardBottom}>
									<div style={styles.rarity}>{cardData.rarity || "Rarity"}</div>
									{cardData.stats && (
										<div style={styles.stats}>{cardData.stats}</div>
									)}
								</div>
							</div>
						)}
					</Card>
				</div>
			</SimpleGrid>
		</>
	);
}

const styles = {
	previewContainer: {
		paddingLeft: "0",
		display: "flex",
		flexDirection: "column",
		alignItems: "center",
	},
	card: {
		width: "22rem",
		backgroundColor: "#1a1a1a",
		borderRadius: "12px",
		overflow: "hidden",
		boxShadow: "0 0.5rem 2rem rgba(0,0,0,0.1)",
		border: "8px solid #8b7355",
		fontFamily: "'Beleren', serif",
	},
	cardHeader: {
		display: "flex",
		justifyContent: "space-between",
		alignItems: "center",
		padding: "12px 15px",
		background: "linear-gradient(to bottom, #d4c5a9 0%, #b8a68a 100%)",
		borderBottom: "2px solid #8b7355",
	},
	cardName: {
		fontSize: "18px",
		fontWeight: "bold",
		color: "#000",
	},
	manaCost: {
		fontSize: "16px",
		fontWeight: "bold",
		color: "#000",
		backgroundColor: "#fff",
		padding: "4px 8px",
		borderRadius: "4px",
	},
	cardArt: {
		width: "100%",
		height: "200px",
		backgroundColor: "#2a2a2a",
		display: "flex",
		alignItems: "center",
		justifyContent: "center",
		borderBottom: "2px solid #8b7355",
	},
	artImage: {
		width: "100%",
		height: "100%",
		objectFit: "cover",
	},
	artPlaceholder: {
		color: "#666",
		fontSize: "14px",
		textAlign: "center",
	},
	typeLine: {
		padding: "8px 15px",
		background: "linear-gradient(to bottom, #d4c5a9 0%, #b8a68a 100%)",
		borderBottom: "2px solid #8b7355",
		fontSize: "14px",
		fontWeight: "600",
		color: "#000",
	},
	rulesBox: {
		padding: "15px",
		background: "linear-gradient(to bottom, #e8dcc8 0%, #d4c5a9 100%)",
		minHeight: "120px",
		fontSize: "13px",
		color: "#000",
	},
	rulesText: {
		marginBottom: "10px",
		lineHeight: "1.4",
	},
	flavorText: {
		marginTop: "10px",
		fontSize: "12px",
		color: "#333",
		fontStyle: "italic",
	},
	cardBottom: {
		display: "flex",
		justifyContent: "space-between",
		alignItems: "center",
		padding: "8px 15px",
		background: "linear-gradient(to bottom, #d4c5a9 0%, #b8a68a 100%)",
		fontSize: "12px",
		color: "#000",
	},
	rarity: {
		textTransform: "uppercase",
		fontWeight: "600",
	},
	stats: {
		fontSize: "20px",
		fontWeight: "bold",
		backgroundColor: "#fff",
		padding: "2px 10px",
		borderRadius: "0.25rem",
	},
	image: {
		borderRadius: "0.75rem",
		boxShadow: "0 0.25rem 0.625rem rgba(0,0,0,0.3)",
		width: "25rem",
	},
};

export default App;
