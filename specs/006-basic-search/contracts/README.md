# API Contracts: Basic Search

This directory contains JSON Schema definitions for the Basic Search feature API endpoints.

## Contracts

### **search-query-params.json**
Query parameters for the search endpoint.

**Endpoint**: `GET /api/search`

**Parameters**:
- `query` (required): Search term (1-200 characters)
- `scope`: Search scope - "all", "lists", "items" (default: "all")
- `page`: Page number (default: 1)
- `pageSize`: Results per page (1-100, default: 20)
- `includeShared`: Include shared lists/items (default: true)

**Example**:
```
GET /api/search?query=milk&scope=all&page=1&pageSize=20
```

---

### **list-search-result.json**
Schema for a single list in search results.

**Properties**:
- `id`: List UUID
- `name`: List name (1-200 chars)
- `description`: Preview (first 100 chars, nullable)
- `owner`: Owner object with `id` and `displayName`
- `totalItems`: Total item count
- `purchasedItems`: Purchased item count
- `isOwner`: Boolean - true if current user owns the list
- `isArchived`: Boolean - true if archived
- `lastUpdatedAt`: ISO 8601 timestamp

**Usage**: Array of these objects in search response `lists.results`

---

### **item-search-result.json**
Schema for a single item in search results.

**Properties**:
- `id`: Item UUID
- `name`: Item name (1-200 chars)
- `quantity`: Number or null
- `unit`: Unit string or null
- `notes`: Preview (first 100 chars, nullable)
- `isPurchased`: Boolean - purchased status
- `category`: Category object (id, name, icon, color) or null
- `parentList`: Parent list context (id, name, isOwner, ownerName)

**Usage**: Array of these objects in search response `items.results`

---

### **search-response.json**
Schema for the complete search API response.

**Structure**:
```json
{
  "query": "milk",
  "scope": "all",
  "lists": {
    "total": 2,
    "results": [ /* array of list-search-result */ ]
  },
  "items": {
    "total": 5,
    "results": [ /* array of item-search-result */ ]
  },
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "hasNext": false,
    "hasPrevious": false
  }
}
```

**Notes**:
- When `scope=lists`, `items.results` will be empty array
- When `scope=items`, `lists.results` will be empty array
- When `scope=all`, both arrays populated (lists limited to 20, items to page size)

---

## API Endpoints

### **Search Endpoint**

```http
GET /api/search
Authorization: Bearer {JWT_TOKEN}
```

**Query Parameters**: See `search-query-params.json`

**Response**: See `search-response.json`

**Status Codes**:
- `200 OK`: Search successful
- `400 Bad Request`: Invalid query parameters
- `401 Unauthorized`: Missing or invalid JWT token
- `500 Internal Server Error`: Server error

**Example Request**:
```bash
curl -X GET "https://api.example.com/api/search?query=apples&scope=items&page=1&pageSize=20" \
  -H "Authorization: Bearer eyJhbGc..."
```

**Example Response**:
```json
{
  "query": "apples",
  "scope": "items",
  "lists": {
    "total": 0,
    "results": []
  },
  "items": {
    "total": 3,
    "results": [
      {
        "id": "item-123",
        "name": "Green Apples",
        "quantity": 5,
        "unit": "lbs",
        "notes": "Granny Smith variety",
        "isPurchased": false,
        "category": {
          "id": "cat-produce",
          "name": "Produce",
          "icon": "🥬",
          "color": "#4CAF50"
        },
        "parentList": {
          "id": "list-456",
          "name": "Weekly Groceries",
          "isOwner": true
        }
      }
    ]
  },
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "hasNext": false,
    "hasPrevious": false
  }
}
```

---

## Validation

All contracts are JSON Schema Draft 07 compliant and can be validated using tools like:

- [ajv](https://ajv.js.org/) (JavaScript)
- [jsonschema](https://python-jsonschema.readthedocs.io/) (Python)
- [JSON Schema Validator](https://www.jsonschemavalidator.net/) (Online)

---

## Related Documentation

- [Feature Specification](../spec.md) - Complete feature requirements
- [API Reference](../../../API_REFERENCE.md) - Full API documentation
- [Testing Guide](../../../TESTING_GUIDE.md) - Contract testing approach

---

**Last Updated**: November 5, 2025

