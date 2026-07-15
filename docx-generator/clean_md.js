const fs = require('fs');

function cleanForClient(mdContent) {
    let lines = mdContent.split('\n');
    let output = [];
    let skipMode = false;
    
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        
        // Skip Phase 13 entirely
        if (line.startsWith('## Phase 13:')) {
            skipMode = true;
            continue;
        }
        
        // Stop skipping when a new phase starts
        if (skipMode && line.startsWith('## Phase ') && !line.startsWith('## Phase 13:')) {
            skipMode = false;
        }
        
        if (skipMode) continue;
        
        // Skip API tables and sections
        if (line.startsWith('### REST API Endpoints')) {
            // Skip until next heading
            while (i + 1 < lines.length && !lines[i+1].startsWith('#')) {
                i++;
            }
            continue;
        }

        // Clean technical terms
        line = line.replace('## Phase 1: Design Database / API Structure', '## Phase 1: Cấu trúc Cơ sở dữ liệu (Database)');
        line = line.replace('Nhóm cần thiết kế cấu trúc dữ liệu và REST API để phục vụ toàn bộ ứng dụng bán camera. Backend sử dụng Node.js Express, dữ liệu được lưu trữ trong MongoDB.', 'Hệ thống sử dụng MongoDB làm cơ sở dữ liệu để lưu trữ toàn bộ thông tin của ứng dụng.');
        line = line.replace('| Nhóm dữ liệu', '| Collection (Tập dữ liệu)');
        line = line.replace('Sơ đồ database hoặc mô tả collection/table.', 'Sơ đồ cơ sở dữ liệu hoặc mô tả các Collection (tương đương với Table/Bảng).');
        line = line.replace('Quan hệ giữa các bảng hoặc collection.', 'Mối quan hệ giữa các Collection.');
        line = line.replace('API endpoint đầy đủ cho REST API.', '');
        
        line = line.replace(/Frontend: Flutter \(Dart\)/g, '');
        line = line.replace(/Backend: Node\.js Express REST API/g, '');
        line = line.replace(/Database: MongoDB/g, 'Hệ quản trị CSDL: MongoDB');
        line = line.replace(/Backend mã hóa mật khẩu bằng bcrypt trước khi lưu vào database\./g, 'Hệ thống sẽ mã hóa bảo mật mật khẩu của người dùng trước khi lưu trữ.');
        line = line.replace(/JWT Token được lưu trữ\./g, 'Lưu trạng thái đăng nhập bảo mật.');
        line = line.replace(/JWT Token/g, 'Phiên đăng nhập (Session/Token)');
        // Remove API path patterns
        line = line.replace(/gọi API [A-Z]+ \/api[a-zA-Z0-9\/\-_\:]+ để/gi, 'hệ thống sẽ');
        line = line.replace(/ứng dụng gọi API [A-Z]+ \/api[a-zA-Z0-9\/\-_\:]+/gi, 'hệ thống');
        line = line.replace(/ứng dụng \/api[a-zA-Z0-9\/\-_\:]+ để/gi, 'hệ thống sẽ');
        line = line.replace(/ứng dụng \/api[a-zA-Z0-9\/\-_\:]+ và/gi, 'hệ thống sẽ');
        line = line.replace(/ứng dụng \/api[a-zA-Z0-9\/\-_\:]+/gi, 'hệ thống');
        line = line.replace(/API `[A-Z]+ \/api[a-zA-Z0-9\/\-_\:]+`/gi, 'hệ thống');
        line = line.replace(/API `[A-Z]+ .*?`/gi, 'hệ thống');
        line = line.replace(/API `.*?`/g, 'hệ thống');
        line = line.replace(/qua API `.*?`/g, 'qua hệ thống');
        line = line.replace(/từ API `.*?`/g, 'từ hệ thống');
        line = line.replace(/API \/api[a-zA-Z0-9\/\-_\:]+/gi, 'hệ thống');
        line = line.replace(/ \/api[a-zA-Z0-9\/\-_\:]+/gi, ' hệ thống');
        
        // Remove remaining generic API terms
        line = line.replace(/gọi API [^\s]+ /gi, '');
        line = line.replace(/Ứng dụng gọi API .*? để /gi, 'Hệ thống sẽ ');
        line = line.replace(/Gọi API `.*?`\./gi, '');
        line = line.replace(/từ API/gi, 'từ hệ thống');
        line = line.replace(/qua API/gi, 'qua hệ thống');
        line = line.replace(/gửi dữ liệu POST lên API\./gi, 'lưu thông tin vào hệ thống.');
        line = line.replace(/Gửi request PUT lên server\./gi, 'cập nhật thông tin.');
        line = line.replace(/Gửi request DELETE lên server\./gi, 'xóa dữ liệu khỏi hệ thống.');
        
        // Final catch-all for any remaining standalone 'API' words
        // We do this after other replacements to avoid double replacements,
        // but let's just make sure it's clean.
        line = line.replace(/\bAPI\b/g, 'hệ thống');

        line = line.replace(/qua Socket\.io/gi, '');
        line = line.replace(/sử dụng WebSocket hoặc Socket\.io để /gi, '');
        line = line.replace(/từ server/gi, 'từ hệ thống');
        line = line.replace(/lên server/gi, 'lên hệ thống');
        line = line.replace(/Backend trả về/gi, 'Hệ thống phản hồi');
        line = line.replace(/Backend kiểm tra/gi, 'Hệ thống kiểm tra');
        line = line.replace(/Backend tự động/gi, 'Hệ thống tự động');
        line = line.replace(/Backend /gi, 'Hệ thống ');
        line = line.replace(/ database/gi, ' cơ sở dữ liệu');
        
        output.push(line);
    }
    
    // Remove empty lines at the beginning
    while (output.length > 0 && output[0].trim() === '') {
        output.shift();
    }
    
    return output.join('\n');
}

const mdContent = fs.readFileSync('../Main Functions Specification - Camera Store.md', 'utf-8');
const clientContent = cleanForClient(mdContent);
fs.writeFileSync('../Client Functions Specification - Camera Store.md', clientContent);
console.log('Successfully generated cleaned markdown!');
