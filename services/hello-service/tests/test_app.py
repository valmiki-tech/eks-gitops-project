import json
import threading
import unittest
from http.server import HTTPServer
from urllib.error import HTTPError
from urllib.request import urlopen

from app import HelloServiceHandler


class HelloServiceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = HTTPServer(("127.0.0.1", 0), HelloServiceHandler)
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(
            target=cls.server.serve_forever,
            daemon=True,
        )
        cls.thread.start()
        cls.base_url = f"http://127.0.0.1:{cls.port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=2)

    def test_health_endpoint(self):
        with urlopen(f"{self.base_url}/health") as response:
            body = json.loads(response.read().decode("utf-8"))
            self.assertEqual(response.status, 200)
            self.assertEqual(body["status"], "healthy")
            self.assertEqual(body["service"], "hello-service")

    def test_home_endpoint(self):
        with urlopen(f"{self.base_url}/") as response:
            body = json.loads(response.read().decode("utf-8"))
            self.assertEqual(response.status, 200)
            self.assertEqual(
                body["message"],
                "Hello from the GitOps deployment! Version 2",
            )
            self.assertEqual(body["status"], "running")

    def test_unknown_endpoint_returns_404(self):
        with self.assertRaises(HTTPError) as error:
            urlopen(f"{self.base_url}/unknown", timeout=3)

        self.assertEqual(error.exception.code, 404)
        body = json.loads(error.exception.read().decode("utf-8"))
        self.assertEqual(body["error"], "Not found")


if __name__ == "__main__":
    unittest.main()
