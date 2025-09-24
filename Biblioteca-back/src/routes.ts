import { Router } from "express"
import {controllerGet, controllerPost, controllerPut, controllerDelete,} from "./controllers"

const router = Router()

router.get("/health", (req, res) => {
    return res.json({status: "ok"})
})


router.get("/api", controllerGet);

router.post("/api", controllerPost);

router.put("/api", controllerPut);

router.delete("/api", controllerDelete);

export default router;