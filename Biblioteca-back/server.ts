import express from 'express';
import cors from "cors";
import dotenv from "dotenv";

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use(cors());

app.listen(PORT, function(){
    console.log(`servidor rodando em: http://localhost:${PORT}`)
});

import router from "./src/routes";

app.use("/", router);
