import { IconDownload } from "@tabler/icons-react";
import { Button } from "@mantine/core";
import "../App.css"
import { useState } from "react";

const Utility = () => {
	const [download, setDownload] = useState(null);
	
	return (
		<div className="utility-section">
			<Button>
				<IconDownload />
			</Button>
		</div>
	);
};

export default Utility;
