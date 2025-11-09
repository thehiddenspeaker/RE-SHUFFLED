import { Group, Text } from "@mantine/core";
import logo from '../assets/reshuffled.png'
const NavBar = () => {
	return (
		<Group gap="xs"  className="navbar">
			<img src={logo} alt="Logo" className="logo" />
			<Text className="logo">Re:Shuffled</Text>
		</Group>
	);
};

export default NavBar;
