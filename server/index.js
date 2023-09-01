const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const documentRouter = require("./routes/document");

const app = express();

const DB =
  "mongodb+srv://6112arjun:Bbmajor7th@cluster0.be4m4el.mongodb.net/?retryWrites=true&w=majority";
app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connected to MongoDB");
  })
  .catch((err) => {
    console.log(err);
  });

const PORT = 3001;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port  http://localhost:${PORT}`);
});

app.get("/", (req, res) => {
  res.send("Hello World!");
});
