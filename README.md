# MiniatureGolf
A simple multiplayer mini golf game made using Love2D and LuaSockets.

## Compiling the game

### Step 1: Install Love

#### For Windows:
1. Go to: [https://love2d.org/](https://love2d.org/)
2. Click Download LÖVE for Windows.
3. Choose the 64-bit Installer (.exe).
4. Run the installer and follow the steps.  

#### For macOS:

1. Go to: [https://love2d.org/](https://love2d.org/)
2. Click Download LÖVE for macOS.
3. You’ll get a .zip file with a LÖVE app inside.
4. Drag LÖVE.app to your Applications folder.

---

### Step 2:  Add LÖVE to Your Environment Path 

#### For Windows: 

To use love in the terminal:

1. Find the LÖVE executable:
	1. Go to C:\Program Files\LOVE or wherever you installed it. 
	2. Inside, locate love.exe.
	
2. Copy the folder path, e.g.:  

```
C:\Program Files\LOVE
```

3. Add it to PATH:
	1. Press Win + S, search for “Environment Variables”, and open it.
	2. Click Environment Variables at the bottom.
	3. Under System variables, find Path and click Edit.
	4. Click New, then paste the folder path.
	5. Click OK on all windows to apply.  
    
4. Test it:
	1. Open Command Prompt and type:  
```
love --version
```

 If it works, you should see the LÖVE version.  

#### For macOS

To run LÖVE from Terminal as love, you need to create a command-line alias:

1. Open the terminal.
2. Run the following:

```
sudo ln -s /Applications/love.app/Contents/MacOS/love/usr/local/bin/love
```

3. Now test it using the command: 

```
love --version
```

 If it works, you should see the LÖVE version.  

---

### Step 3: Cloning the Repository

1. Open your terminal
2. Choose a destination for the repository
3. Clone the repository:

```
git clone https://github.com/camblsoup/MiniatureGolf.git
```

---
### Step 4: Running Miniature Gӧlf

Now that LÖVE is installed and accessible via the terminal:
#### To host or run the game:

1. Open your terminal.
2. Navigate to the folder where `/Game` is by doing:

```
cd path/to/the/repository/MiniatureGolf/Game
```

3. Run the game by typing the following into the terminal

```
love .
```

It is important that you are in the `/Game` folder as the code relies on a valid path to the `/Server` folder